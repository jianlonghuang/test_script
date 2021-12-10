#include <stdio.h>  
#include <string.h>  
#include <unistd.h>  
#include <sys/ioctl.h>  
#include <stdlib.h>  
#include <fcntl.h>  
#include <sys/io.h> 

#define EEPROM_SIZE				256
#define HEAD_REVISION			0x01
#define HEAD_ATOMS_NUM			2
#define OFFSET_EEPLEN			8

#define TYPE_VENDOR_INFO		0x0001
#define TYPE_CUSTOM_DATA		0x0004

#define LEN_VENDOR_STRING		0x20
#define LEN_PRODUCT_STRING		0x20

#define OVERTIME				5
#define EEPROM_DEV "/sys/bus/i2c/drivers/at24/0-0050/eeprom"
#define EEPROM_OFFSET	0x100
#define MAC_ADDR_LEN	17
#define CRC16 0x8005

struct t_eeprom_header {
	char signature[4];
	char version;
	char reversed;
	unsigned short numatoms;
	unsigned int eeplen;
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
	char ether_mac_0[6];
	char reversed[2];
};

struct t_atom1_info {
	unsigned short type;
	unsigned short count;
	unsigned int data_len;
	struct t_vendor_info vendor_info;
	unsigned short crc16;
};

struct t_atom4_info {
	unsigned short type;
	unsigned short count;
	unsigned int data_len;
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

static void scan_input_mac(char *dst)
{
	char mac[20];
	int i = 0;
	int mac_invalid = 1;
	int mac_cnt;
	char **ppmac;

	while(mac_invalid){
		printf("Please enter ETH0 mac address: (xx-xx-xx-xx-xx-xx)\r\n");
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

void main(void)
{
	int i=0;
	unsigned char eth0_mac_addr[6] = {0};
	unsigned char psn[LEN_PRODUCT_STRING] = {0};

	struct t_eeprom_header *p_header = &g_eeprom_data.eeprom_header;
	struct t_atom1_info *p_atom1_info = &g_eeprom_data.atom1_info;
	struct t_atom4_info *p_atom4_info = &g_eeprom_data.atom4_info;

	memset(&g_eeprom_data, 0x0, sizeof(g_eeprom_data));

	scan_input_mac(eth0_mac_addr);
	scan_input_sn(psn);

	memcpy((void *)p_header->signature, (void *)signature, sizeof(p_header->signature));
	
	p_header->version = HEAD_REVISION;
	p_header->reversed = 0;
	p_header->numatoms = HEAD_ATOMS_NUM;
	p_header->eeplen = sizeof(g_eeprom_data);
	printf("eeplen = %d\r\n", p_header->eeplen);
	printf("eeprom_header = %ld\r\n", sizeof(g_eeprom_data.eeprom_header));
	printf("atom1_info = %ld\r\n", sizeof(g_eeprom_data.atom1_info));
	printf("atom4_info = %ld\r\n", sizeof(g_eeprom_data.atom4_info));

	p_atom1_info->type = TYPE_VENDOR_INFO;
	p_atom1_info->count = 1;
	p_atom1_info->data_len = sizeof(p_atom1_info->vendor_info) + 2;
	memset(p_atom1_info->vendor_info.uuid, 0x0, sizeof(p_atom1_info->vendor_info.uuid));
	p_atom1_info->vendor_info.pid = 0;
	p_atom1_info->vendor_info.pver = 0;
	p_atom1_info->vendor_info.vslen = LEN_VENDOR_STRING;
	p_atom1_info->vendor_info.pslen = LEN_PRODUCT_STRING;
	memcpy(p_atom1_info->vendor_info.vstr, starfive_vstr, sizeof(p_atom1_info->vendor_info.vstr));
	memcpy(p_atom1_info->vendor_info.pstr, psn, sizeof(p_atom1_info->vendor_info.pstr));
	p_atom1_info->crc16 = checksum_crc16((unsigned char *)p_atom1_info, sizeof(g_eeprom_data.atom1_info) - 2);
	
	p_atom4_info->type = TYPE_CUSTOM_DATA;
	p_atom4_info->count = 0x02;
	p_atom4_info->data_len = sizeof(p_atom4_info->custom_info) + 2;
	p_atom4_info->custom_info.version = 0x01;
	memcpy(p_atom4_info->custom_info.ether_mac_0, eth0_mac_addr, sizeof(p_atom4_info->custom_info.ether_mac_0));
	p_atom4_info->crc16 = checksum_crc16((unsigned char *)p_atom4_info, sizeof(g_eeprom_data.atom4_info) - 2);
	
	eeprom_write_data((unsigned char *)&g_eeprom_data, sizeof(g_eeprom_data));

}
