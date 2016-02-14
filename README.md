# Esp8266-Arduino-Makefile
Forked from thunderace/Esp8266-Arduino-Makefile : https://github.com/thunderace/Esp8266-Arduino-Makefile

This is still under development.. Not yet working.

Creates a Arduino ESP8266 development environment based on Makefiles.
Tested with Windows 7 and cygwinx64, and Ubuntu 14.04 x64.

## Changelog
14/Feb/2016 : Allan Inda
- forked from thunderace/Esp8266-Arduino-Makefile (Latest commit bf8cc59  on Dec 8, 2015)
- added install script for cygwinx64 (tested on Windows 7 Pro)
- pull Arduino IDE into root directory

## Installation Windows
- Install cygwin. Use the base install, but also include 'make' and 'perl YAML'.
- Open a cygwin terminal
- mkdir ~/ESP8266
- cd ~/ESP8266
- git clone --recursive https://github.com/intrepidor/Esp8266-Arduino-Makefile.git ESP8266-Arduino-Makefile
- cd Esp8266-Arduino-Makefile
- chmod+x install-cygwin.sh
- ./install-cygwin.sh

## Installation and test for Ubuntu 14.04.03 LTS
- sudo apt-get update
- sudo apt-get install libconfig-yaml-perl
- cd ~/
- mkdir ESP8266
- cd ESP8266
- git clone --recursive https://github.com/intrepidor/Esp8266-Arduino-Makefile.git ESP8266-Arduino-Makefile
- cd ESP8266-Arduino-Makefile
- ./install-ubuntu.sh
- cd example/AdvancedWebServer
- make

## General Usage
- In your sketch directory place a Makefile that defines anything that is project specific and follow that with a line `include /path_to_Esp8266-Arduino-Makefile_directory/esp8266Arduino.mk` (see example)
- `make upload` should build your sketch and upload it...


 
