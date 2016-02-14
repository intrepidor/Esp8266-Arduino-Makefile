# Esp8266-Arduino-Makefile

This is still under development.. Not yet working.

Makefile to build with Arduino code for ESP8266 target using Windows 7 and cygwinx64.
Forked from thunderace/Esp8266-Arduino-Makefile : https://github.com/thunderace/Esp8266-Arduino-Makefile

## Changelog
07/Feb/2016 : Allan Inda
- forked from thunderace/Esp8266-Arduino-Makefile (Latest commit bf8cc59  on Dec 8, 2015)
- added install script for cygwinx64 (tested on Windows 7 Pro)
- pull Arduino IDE into root directory

## Installation Windows
- Install cygwin. Use the base install, but also include 'make' and 'perl YAML'.
- Clone this repository : `git clone --recursive https://github.com/intrepidor/Esp8266-Arduino-Makefile.git ESP8266-Arduino-Makefile`
- Install third party tools : `cd Esp8266-Arduino-Makefile && chmod+x install-cygwin.sh`
- In your sketch directory place a Makefile that defines anything that is project specific and follow that with a line `include /path_to_Esp8266-Arduino-Makefile_directory/esp8266Arduino.mk` (see example)
- `make upload` should build your sketch and upload it...

## Installation and test for Ubuntu 14.04.03 LTS
- sudo apt-get update
- sudo apt-get install libconfig-yaml-perl
- cd ~/
- mkdir ESP8266
- cd ESP8266
- git clone --recursive https://github.com/intrepidor/Esp8266-Arduino-Makefile.git ESP8266-Arduino-Makefile
- ./install-ubuntu.sh
- cd example/AdvancedWebServer
- make


 