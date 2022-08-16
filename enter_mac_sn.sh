#! /bin/sh


eeprom_dev=/sys/bus/i2c/devices/5-0050/eeprom
eeprom_data=$0

eeprom_offset=0
eeprom_size=136


dd if=$eeprom_data of=$eeprom_dev bs=1 seek=$eeprom_offset count=$eeprom_size

cat $eeprom_dev | hexdump
