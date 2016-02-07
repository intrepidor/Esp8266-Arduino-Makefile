# Esp8266-Arduino-Makefile
Makefile to build arduino code for ESP8266 under linux (tested on debian X64) and Windows 7 with cygwinx64.
Forked from thunderace/Esp8266-Arduino-Makefile : https://github.com/thunderace/Esp8266-Arduino-Makefile

## Changelog
07/Feb/2016 : Allan Inda
- forked from thunderace/Esp8266-Arduino-Makefile (Latest commit bf8cc59  on Dec 8, 2015)
- added install script for cygwinx64 (tested on Windows 7 Pro)
- pull Arduino IDE into root directory

## Installation
- Clone this repository : `git clone --recursive https://github.com/intrepidor/Esp8266-Arduino-Makefile.git ESP8266-Arduino-Makefile_intrepidor`
- Install third party tools : 
   for Windows : `cd Esp8266-Arduino-Makefile_intrepidor && chmod+x install-cygwin.sh`
   for 64 bits linux : `cd Esp8266-Arduino-Makefile && chmod+x install-x86_64-pc-linux-gnu.sh && ./install-x86_64-pc-linux-gnu.sh && cd ..` 
   for 32 bits linux : `cd Esp8266-Arduino-Makefile && chmod+x install-i686-pc-linux-gnu.sh && ./install-i686-pc-linux-gnu.sh && cd ..` 
- In your sketch directory place a Makefile that defines anything that is project specific and follow that with a line `include /path_to_Esp8266-Arduino-Makefile_directory/esp8266Arduino.mk` (see example)
- `make upload` should build your sketch and upload it...

#dependencies
- this project uses the last esp8266/Arduino repository (not stable) and the last stagging esptool and xtensa-lx106 toolchain

## TODO
- build user libs in their own directory to avoid problems with multiple files with same name.


