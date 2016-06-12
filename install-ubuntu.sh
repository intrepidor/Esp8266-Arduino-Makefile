# Script to install and setup environment for ESP8266 Arduino development with Makefiles

# make sure YAML is installed
#sudo apt-get update
#sudo apt-get install libconfig-yaml-perl

declare DEBUG="false"

#declare ARDUINO_VER=1.6.5-r5
declare ARDUINO_VER=1.6.9
#declare ESP8266_VER=master
declare ESP8266_VER=2.3.0-rc1
declare MKSPIFFS_VER=0.1.2
declare ESPTOOL_VER=0.4.8
#declare ESP_SDK_VER=1.4.0

declare DESTINATION=extra_libs
declare XLIBINC=""
declare PWD=`pwd`
#declare ROOT=`cygpath -m $PWD`

# save anything that is downloaded for faster reinstalls
declare DOWNLOAD_CACHE=../download
mkdir $DOWNLOAD_CACHE

######
download_and_install_library() {
	local _URL="https://github.com/$1"	
	local _ARCH=$2
	local _NAME=$3
	mkdir -p $DESTINATION
	echo "URL=$_URL"
	echo "Download and install $_NAME library ..."
	cp -px $DOWNLOAD_CACHE/$_ARCH .
	wget -nv --no-clobber --no-check-certificate $_URL -O $_ARCH
	cp -px $_ARCH $DOWNLOAD_CACHE
	DIR=`zipinfo -1 $_ARCH | head -n 1 | awk -F\/ '{print $1}'`
	unzip -qo $_ARCH
	rm $_ARCH
	mv $DIR $_NAME
	cp -frpx $_NAME $DESTINATION
	rm -r --one-file-system $_NAME	
}
if [ $DEBUG == "false" ]
then
# Get MKSPIFFS Tool
cp -np $DOWNLOAD_CACHE/mkspiffs-$MKSPIFFS_VER-linux64.tar.gz .
wget --no-clobber https://github.com/igrr/mkspiffs/releases/download/$MKSPIFFS_VER/mkspiffs-$MKSPIFFS_VER-linux64.tar.gz
tar xfz mkspiffs-$MKSPIFFS_VER-linux64.tar.gz
mv mkspiffs-$MKSPIFFS_VER-linux64/mkspiffs bin
rmdir mkspiffs-$MKSPIFFS_VER-linux64
mv mkspiffs-$MKSPIFFS_VER-linux64.tar.gz $DOWNLOAD_CACHE
chmod +x bin/mkspiffs

# Get Xtensa GCC Compiler
cp -np $DOWNLOAD_CACHE/linux64-xtensa-lx106-elf-gb404fb9.tar.gz .
wget --no-clobber http://arduino.esp8266.com/linux64-xtensa-lx106-elf-gb404fb9.tar.gz
cp linux64-xtensa-lx106-elf-gb404fb9.tar.gz $DOWNLOAD_CACHE
tar xfz linux64-xtensa-lx106-elf-gb404fb9.tar.gz
rm linux64-xtensa-lx106-elf-gb404fb9.tar.gz

# Get ESPTOOL
cp -np $DOWNLOAD_CACHE/esptool-$ESPTOOL_VER-linux64.tar.gz .
wget --no-clobber https://github.com/igrr/esptool-ck/releases/download/$ESPTOOL_VER/esptool-$ESPTOOL_VER-linux64.tar.gz
cp esptool-$ESPTOOL_VER-linux64.tar.gz $DOWNLOAD_CACHE
tar xfv esptool-$ESPTOOL_VER-linux64.tar.gz
mv esptool-$ESPTOOL_VER-linux64/esptool bin
rmdir esptool-$ESPTOOL_VER-linux64
chmod +x bin/esptool
mv esptool-$ESPTOOL_VER-linux64.tar.gz $DOWNLOAD_CACHE

# Get Arduino IDE
rm -f arduino # remove any existing softlinks so they don't get in the way
cp -p $DOWNLOAD_CACHE/arduino-$ARDUINO_VER-linux64.tar.xz .
wget --no-clobber http://arduino.cc/download.php?f=/arduino-$ARDUINO_VER-linux64.tar.xz -O arduino-$ARDUINO_VER-linux64.tar.xz
cp -np arduino-$ARDUINO_VER-linux64.tar.xz $DOWNLOAD_CACHE
unxz arduino-$ARDUINO_VER-linux64.tar.xz
tar xf arduino-$ARDUINO_VER-linux64.tar
rm arduino-$ARDUINO_VER-linux64.tar

# Get Arduino core for ESP8266 chip
echo "Installing Arduino for ESP8266"
if [ $ESP8266_VER == "master" ]
then
  echo "Getting master branch for ESP8266_Arduino"
  cp -np $DOWNLOAD_CACHE/$ESP8266_VER.zip .
  wget --no-clobber https://github.com/esp8266/Arduino/archive/$ESP8266_VER.zip
  cp -np $ESP8266_VER.zip $DOWNLOAD_CACHE
  unzip -qo $ESP8266_VER.zip
  mv Arduino-$ESP8266_VER $ESP8266_VER
  rm $ESP8266_VER.zip
else
  cp -np $DOWNLOAD_CACHE/esp8266-$ESP8266_VER.zip .
  wget --no-clobber https://github.com/esp8266/Arduino/releases/download/$ESP8266_VER/esp8266-$ESP8266_VER.zip
  cp -np esp8266-$ESP8266_VER.zip $DOWNLOAD_CACHE
  unzip -qo esp8266-$ESP8266_VER.zip
  rm esp8266-$ESP8266_VER.zip
fi

# Copy ESP8266_Arduino Libraries
mkdir -p arduino-$ARDUINO_VER/hardware/esp8266com
if [ $ESP8266_VER == "master" ]
then
  mv  $ESP8266_VER arduino-$ARDUINO_VER/hardware/esp8266com/esp8266
else
  mv  esp8266-$ESP8266_VER arduino-$ARDUINO_VER/hardware/esp8266com/esp8266
fi
fi

# Create softlink to arduino library so the makefile does not need to know the version
ln -sf arduino-$ARDUINO_VER arduino

# Install ESP8266 RTOS SDK
#icp -r $DOWNLOAD_CACHE/esp8266_rtos_sdk-$ESP_SDK_VER.zip
#wget --no-clobber https://github.com/espressif/ESP8266_RTOS_SDK/archive/v$ESP_SDK_VER.zip
#mv v$ESP_SDK_VER.zip esp8266_rtos_sdk-$ESP_SDK_VER.zip
#cp -np esp8266_rtos_sdk-$ESP_SDK_VER.zip $DOWNLOAD_CACHE
#unzip -qo esp8266_rtos_sdk-$ESP_SDK_VER.zip
#rm esp8266_rtos_sdk-$ESP_SDK_VER.zip


######
# Install additional libraries
download_and_install_library "adafruit/DHT-sensor-library/archive/1.2.3.zip" "DHT_sensor_library-1.2.3-github.zip" "DHT"
download_and_install_library "tzapu/WiFiManager/archive/0.9.zip"             "WiFiManager-0.9-github.zip"          "WiFiManager"
