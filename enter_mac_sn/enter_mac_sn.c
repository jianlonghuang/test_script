#include <stdio.h>  
#include <string.h>  
#include <unistd.h>  
#include <sys/ioctl.h>  
#include <stdlib.h>  
#include <fcntl.h>  
#include <ctype.h>
//#include <sys/io.h> 

#define EEPROM_SIZE				512
#define HEAD_REVISION			0x02
#define HEAD_ATOMS_NUM			2
#define OFFSET_EEPLEN			8

#define TYPE_VENDOR_INFO		0x0001
#define TYPE_CUSTOM_DATA		0x0004

#define LEN_VENDOR_STRING		0x20
#define LEN_PRODUCT_STRING		0x20

#define OVERTIME				5
#define EEPROM_DEV "/sys/bus/i2c/drivers/at24/5-0050/eeprom"
#define EEPROM_OFFSET	0x0
#define MAC_ADDR_LEN	17
#define CRC16 0x8005
#define EEPROM_LOG "EEPROM.log"

struct t_eeprom_header {
	char signature[4];
	char version;
	char reversed;
	unsigned short numatoms;
	unsigned int eeplen;
};

struct t_atom_header {
	unsigned short type;
	unsigned short count;
	unsigned int dlen;
};

struct t_vendor_info {
	char uuid[16];
	unsigned short pid;
	unsigned short pver;
	char vslen;
	char pslen;
	char vstr[LEN_VENDOR_STRING];
	char pstr[LEN_PRODUCT_STRING];
};

struct t_custom_info {
	unsigned short version;
	char pcb_version;
	char bom_version;
	char ether_mac_0[6];
	char ether_mac_1[6];
	char reserved[2];
};

struct t_atom1_info {
	struct t_atom_header atom_header;
	struct t_vendor_info vendor_info;
	unsigned short crc16;
};

struct t_atom4_info {
	struct t_atom_header atom_header;
	struct t_custom_info custom_info;
	unsigned short crc16;
};

struct t_eeprom_data {
	struct t_eeprom_header eeprom_header;
	struct t_atom1_info atom1_info;
	struct t_atom4_info atom4_info;
};

struct t_eeprom_data g_eeprom_data;

char signature[4] = {0x53, 0x46, 0x56, 0x46};	//SFVF
char starfive_vstr[LEN_VENDOR_STRING] = "StarFive Technology Co., Ltd.\0\0\0";
const unsigned char *mac_separator =  "-";

static unsigned short checksum_crc16(unsigned char *data, unsigned short size)
{
	int i, j = 0x0001;
	unsigned short out = 0, crc = 0;
	int bits_read = 0, bit_flag;

	/* Sanity check: */
	if((data == NULL) || size == 0)
		return 0;

	while(size > 0) {
		bit_flag = out >> 15;

		/* Get next bit: */
		out <<= 1;
		// item a) work from the least significant bits
		out |= (*data >> bits_read) & 1;

		/* Increment bit counter: */
		bits_read++;
		if(bits_read > 7) {
			bits_read = 0;
			data++;
			size--;
		}

		/* Cycle check: */
		if(bit_flag)
			out ^= CRC16;
	}

	// item b) "push out" the last 16 bits
	for (i = 0; i < 16; ++i) {
		bit_flag = out >> 15;
		out <<= 1;
		if(bit_flag)
			out ^= CRC16;
	}

	// item c) reverse the bits
	for (i = 0x8000; i != 0; i >>=1, j <<= 1) {
		if (i & out)
			crc |= j;
	}

	return crc;
}


static char** str_split(char *src, const char *separator, int *cnt)
{
	char **dst = NULL;
	char *tmp = NULL;
	int index = 0;

	tmp = strtok(src, separator); 
	while(tmp){
		dst = realloc (dst, sizeof (char*) * ++index);
			if(dst == NULL){
				return dst;
			}
		dst[index - 1] = tmp;
		tmp = strtok(NULL, separator);
	}
	*cnt = index;
	return dst;
}

static int check_mac_addr_invalid(char *mac, int len)
{
	int i;
	int mac_invalid = 0;
	
	if(len < MAC_ADDR_LEN){
		mac_invalid = 1;
		return mac_invalid;
	}

	for(i = 0; i < len; i++){
		if((mac[i] >= '0' && mac[i] <= '9') || (mac[i] >= 'a' && mac[i] <= 'f') 
			|| (mac[i] >= 'A' && mac[i] <= 'F') || (mac[i] == '-')){
				mac_invalid = 0;
		}
		else{
			mac_invalid = 1;
			printf("bad mac address\r\n");
			break;
		}
	}
	return mac_invalid;
}

static void scan_input_mac(int index, char *dst)
{
	char mac[20];
	int i = 0;
	int mac_invalid = 1;
	int mac_cnt;
	char **ppmac;

	while(mac_invalid){
		if (index == 0)
			printf("Please enter ETH0 mac address: (xx-xx-xx-xx-xx-xx)\r\n");
		else
			printf("Please enter ETH1 mac address: (xx-xx-xx-xx-xx-xx)\r\n");

		scanf("%17s[^\n]", mac);

		mac_invalid = check_mac_addr_invalid(mac, strlen(mac));
		if(i++ >= OVERTIME){
			break;
		}
	}

	if(!mac_invalid){
		ppmac = str_split(mac, mac_separator, &mac_cnt);
		if(ppmac && mac_cnt == 6){
			dst[0] = strtoul(*(ppmac + 0), NULL, 16) & 0xff;
			dst[1] = strtoul(*(ppmac + 1), NULL, 16) & 0xff;
			dst[2] = strtoul(*(ppmac + 2), NULL, 16) & 0xff;
			dst[3] = strtoul(*(ppmac + 3), NULL, 16) & 0xff;
			dst[4] = strtoul(*(ppmac + 4), NULL, 16) & 0xff;
			dst[5] = strtoul(*(ppmac + 5), NULL, 16) & 0xff;
		}
	}
	else{
		dst[0] = 0xff;
		dst[1] = 0xff;
		dst[2] = 0xff;
		dst[3] = 0xff;
		dst[4] = 0xff;
		dst[5] = 0xff;
	}
}

static void scan_input_sn(char *dst)
{
	printf("Please enter SN: (XXXXXXXX-XXXXX-XXXX-XXXXXXX)\r\n");
	scanf("%32s", dst);	
}

static unsigned char checksum(char *str, int len)
{
	int i;
	unsigned char sum = 0;

	for(i = 0; i < len; i++){
		sum += str[i];
	}
	sum = ~sum + 1;
	return sum;
}

static int eeprom_write_data(char *data, int len)
{
	int fd = 0;
	int ret = 0;
	char rbuf[EEPROM_SIZE] = {0};
	unsigned char sum = 0;

	fd = open(EEPROM_DEV, O_RDWR);  
	if(fd < 0){  
		printf("Open %s fail\n", EEPROM_DEV);  
		return -1;  
	}

	lseek(fd, EEPROM_OFFSET, SEEK_SET);

	ret = write(fd, data, len);  
	if(ret < 0){  
		printf("Write error\n");  
		return -1;  
	}

	lseek(fd, EEPROM_OFFSET, SEEK_SET);
	ret = read(fd, rbuf, len); 
	if(ret < 0){  
		printf("Read error\n");  
		return -1;  
	}
 
	for(int i = 0; i < len; i++){
		if(i % 16 == 0)
			printf("\r\n");
		printf("%02x ", rbuf[i]);
	}
	printf("\r\n");

	close(fd);
	return 0;
}

static int eeprom_read_data(char *data)
{
	int fd = 0;
	int ret = 0;
	unsigned short crc16 = 0;
	struct t_eeprom_data eeprom_data_tmp;
	struct t_eeprom_header *p_header = &eeprom_data_tmp.eeprom_header;
	struct t_atom1_info *p_atom1_info = &eeprom_data_tmp.atom1_info;
	struct t_atom4_info *p_atom4_info = &eeprom_data_tmp.atom4_info;

	fd = open(EEPROM_DEV, O_RDWR);
	if (fd < 0) {
		printf("Open %s fail\n", EEPROM_DEV);
		return -1;
	}

	lseek(fd, EEPROM_OFFSET, SEEK_SET);

	ret = read(fd, data, sizeof(eeprom_data_tmp));
	if (ret < 0) {
		printf("Read error\n");
		return -1;
	}

	memcpy(&eeprom_data_tmp, data, sizeof(eeprom_data_tmp));

	for (int i = 0; i < 4; i++)
		printf("%x\n", p_header->signature[i]);
	if (strncmp((void *)p_header->signature, (void *)signature, sizeof(p_header->signature)) != 0) {
		printf("eeprom data header wrong\n");
		return -1;
	}

	crc16 = checksum_crc16((unsigned char *)p_atom1_info, sizeof(eeprom_data_tmp.atom1_info) - 2);
	if (crc16 != p_atom1_info->crc16) {
		printf("eeprom data atom1 crc wrong\n");
		return -1;
	}

	crc16 = checksum_crc16((unsigned char *)p_atom4_info, sizeof(eeprom_data_tmp.atom4_info) - 2);
	if (crc16 != p_atom4_info->crc16) {
		printf("eeprom data atom4 crc wrong\n");
		return -1;
	}

	close(fd);
	return 0;
}

static void mac_stringtohex(char *str, char *hex)
{
	char *p = strtok(str, ":");
	int i = 0;

	while(p != NULL) {
		if (i++ >= 6) {
			break;
		}
		*hex++ = (int)strtol(p, NULL, 16);
		p = strtok(NULL, ":");
	}
}

static int check_char_hex(char *str)
{
	int i = 0;

	while(*str != 0) {
		if(isxdigit(*str) == 0 && *str != ':')
			return -1;
		str++;
		i++;
	}

	if (i != 17)
		return -1;
	else
		return 0;
}

static int check_arg_valid(int argc, char *argv[])
{
	char bom_version = 0;

	for (int i = 0; i < argc; i++)
		printf("argv[%d]: %s\n", i, argv[i]);

	if (argc != 6) {
		printf("write eeprom argc wrong: %d\n", argc);
		return -1;
	}

	if (strlen(argv[1]) != LEN_PRODUCT_STRING - 1) {
		printf("write eeprom psn len wrong: %ld\n", strlen(argv[1]));
		return -1;
	}

	memcpy(&bom_version, argv[2], 1);
	if (bom_version < 'A' || bom_version > 'Z') {
		printf("write eeprom bom version wrong: %d\n", bom_version);
		return -1;
	}

	if(check_char_hex(argv[4]) != 0) {
		printf("write eeprom eth0 mac wrong\n");
		return -1;
	}

	if(check_char_hex(argv[5]) != 0) {
		printf("write eeprom eth1 mac wrong\n");
		return -1;
	}

	return 0;
}


static void write_eeprom_log(char *result)
{
	FILE* pf = fopen(EEPROM_LOG, "w+");
	if (pf == NULL) {
		printf("open %s fail\n", EEPROM_LOG);
		return;
	}

	fputs(result, pf);

	fclose(pf);

	pf = NULL;
}

void main(int argc, char *argv[])
{
	int i=0;
	char *use_default;
	unsigned char eth0_mac_addr[6] = {0x6c, 0xcf, 0x39, 0x6c, 0xde, 0x12};
	unsigned char eth1_mac_addr[6] = {0x6c, 0xcf, 0x39, 0x7c, 0xae, 0x13};
	unsigned char psn[LEN_PRODUCT_STRING] = "VF7110A1-2228-D008E000-00000001\0";
	char pcb_version = 0x01;
	char bom_version = 'A';
	char rbuf[EEPROM_SIZE] = {0};
	int ret;

	struct t_eeprom_header *p_header = &g_eeprom_data.eeprom_header;
	struct t_atom1_info *p_atom1_info = &g_eeprom_data.atom1_info;
	struct t_atom4_info *p_atom4_info = &g_eeprom_data.atom4_info;

	printf("Usage: ./enter_mac_sn sn bom_version pcb_version eth0_mac eth1_mac\n");
	printf("       ./enter_mac_sn VF7110A1-2228-D008E000-00000001 A 1 6c:cf:39:6c:de:12 6c:cf:39:7c:ae:13\n");

	if (check_arg_valid(argc, argv) == 0) {
		memset(psn, 0x0, LEN_PRODUCT_STRING);
		memcpy(psn, argv[1], LEN_PRODUCT_STRING - 1);
		printf("psn %ld: %s\n", strlen(argv[1]), psn);
		memcpy(&bom_version, argv[2], 1);
		pcb_version = (unsigned char)strtoul(argv[3], NULL, 16);
		printf("bom = %d, pcb = %d\n", bom_version, pcb_version);

		mac_stringtohex(argv[4], eth0_mac_addr);
		mac_stringtohex(argv[5], eth1_mac_addr);
	} else {
		write_eeprom_log("FAIL\n");
		return;
	}


	if (eeprom_read_data(rbuf) == 0) {
		memcpy((void *)&g_eeprom_data, (void *)rbuf, sizeof(g_eeprom_data));
		memcpy(p_atom1_info->vendor_info.pstr, psn, sizeof(p_atom1_info->vendor_info.pstr));
		p_atom1_info->crc16 = checksum_crc16((unsigned char *)p_atom1_info, sizeof(g_eeprom_data.atom1_info) - 2);

		p_atom4_info->custom_info.pcb_version = pcb_version;
		p_atom4_info->custom_info.bom_version = bom_version;
		memcpy(p_atom4_info->custom_info.ether_mac_0, eth0_mac_addr, sizeof(p_atom4_info->custom_info.ether_mac_0));
		memcpy(p_atom4_info->custom_info.ether_mac_1, eth1_mac_addr, sizeof(p_atom4_info->custom_info.ether_mac_1));
		p_atom4_info->crc16 = checksum_crc16((unsigned char *)p_atom4_info, sizeof(g_eeprom_data.atom4_info) - 2);
	} else {

		memset(&g_eeprom_data, 0x0, sizeof(g_eeprom_data));
		memcpy((void *)p_header->signature, (void *)signature, sizeof(p_header->signature));

		p_header->version = HEAD_REVISION;
		p_header->reversed = 0;
		p_header->numatoms = HEAD_ATOMS_NUM;
		p_header->eeplen = sizeof(g_eeprom_data);
		printf("eeplen = %d\r\n", p_header->eeplen);
		printf("eeprom_header = %ld\r\n", sizeof(g_eeprom_data.eeprom_header));
		printf("atom1_info = %ld\r\n", sizeof(g_eeprom_data.atom1_info));
		printf("atom4_info = %ld\r\n", sizeof(g_eeprom_data.atom4_info));

		p_atom1_info->atom_header.type = TYPE_VENDOR_INFO;
		p_atom1_info->atom_header.count = 1;
		p_atom1_info->atom_header.dlen = sizeof(p_atom1_info->vendor_info) + 2;
		memset(p_atom1_info->vendor_info.uuid, 0x0, sizeof(p_atom1_info->vendor_info.uuid));
		p_atom1_info->vendor_info.pid = 0;
		p_atom1_info->vendor_info.pver = 0;
		p_atom1_info->vendor_info.vslen = LEN_VENDOR_STRING;
		p_atom1_info->vendor_info.pslen = LEN_PRODUCT_STRING;
		memcpy(p_atom1_info->vendor_info.vstr, starfive_vstr, sizeof(p_atom1_info->vendor_info.vstr));
		memcpy(p_atom1_info->vendor_info.pstr, psn, sizeof(p_atom1_info->vendor_info.pstr));
		p_atom1_info->crc16 = checksum_crc16((unsigned char *)p_atom1_info, sizeof(g_eeprom_data.atom1_info) - 2);

		p_atom4_info->atom_header.type = TYPE_CUSTOM_DATA;
		p_atom4_info->atom_header.count = 0x02;
		p_atom4_info->atom_header.dlen = sizeof(p_atom4_info->custom_info) + 2;
		p_atom4_info->custom_info.version = 0x02;
		p_atom4_info->custom_info.pcb_version = pcb_version;
		p_atom4_info->custom_info.bom_version = bom_version;
		p_atom4_info->custom_info.reserved[0] = 0;
		p_atom4_info->custom_info.reserved[1] = 0;
		memcpy(p_atom4_info->custom_info.ether_mac_0, eth0_mac_addr, sizeof(p_atom4_info->custom_info.ether_mac_0));
		memcpy(p_atom4_info->custom_info.ether_mac_1, eth1_mac_addr, sizeof(p_atom4_info->custom_info.ether_mac_1));
		p_atom4_info->crc16 = checksum_crc16((unsigned char *)p_atom4_info, sizeof(g_eeprom_data.atom4_info) - 2);
	}

	ret = eeprom_write_data((unsigned char *)&g_eeprom_data, sizeof(g_eeprom_data));
	if (ret == 0)
		write_eeprom_log("PASS\n");
	else
		write_eeprom_log("FAIL\n");

}
