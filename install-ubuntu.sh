# Script to install and setup environment for ESP8266 Arduino development with Makefiles

# make sure YAML is installed
#sudo apt-get update
#sudo apt-get install libconfig-yaml-perl

declare DEBUG="false"

# https://github.com/esp8266/Basic/archive/master.zip
# adaFruit/ESP8266-Arduino --- https://github.com/adafruit/ESP8266-Arduino/archive/1.6.4.zip
# adaFruit_ESP8266-Arduino_1.6.4.zip
#declare ADAFRUIT_ARDUINO_VER=1.6.4

declare ARDUINO_VER=1.6.9
declare ESP8266_VER=2.3.0-rc1
declare MKSPIFFS_VER=0.1.2
declare ESPTOOL_VER=0.4.8

declare DESTINATION=extra_libs
declare XLIBINC=""
declare PWD=`pwd`
#declare ROOT=`cygpath -m $PWD`

# save anything that is downloaded for faster reinstalls
declare DOWNLOAD_CACHE=../download
mkdir $DOWNLOAD_CACHE

######
dlAndInstallLib() {
	local _URL="https://github.com/$1"	
	local _ARCH=$2
	local _NAME=$3
	local _USECACHE=$4
	mkdir -p $DESTINATION
	echo "Getting and installing $_NAME library ..."

	if [ $_USECACHE == "nocache" ]
	then
		echo " .. Ignoring cache copy for $_NAME"
		wget -nv --no-check-certificate $_URL -O $_ARCH
	else
#		echo " .. Using cached copy if available for $_NAME"
		cp -px $DOWNLOAD_CACHE/$_ARCH .
		wget -nv --no-clobber --no-check-certificate $_URL -O $_ARCH
	fi
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

# Create softlink to arduino library so the makefile does not need to know the version
ln -sf arduino-$ARDUINO_VER arduino

# Install ESP8266 RTOS SDK
#icp -r $DOWNLOAD_CACHE/esp8266_rtos_sdk-$ESP_SDK_VER.zip
#wget --no-clobber https://github.com/espressif/ESP8266_RTOS_SDK/archive/v$ESP_SDK_VER.zip
#mv v$ESP_SDK_VER.zip esp8266_rtos_sdk-$ESP_SDK_VER.zip
#cp -np esp8266_rtos_sdk-$ESP_SDK_VER.zip $DOWNLOAD_CACHE
#unzip -qo esp8266_rtos_sdk-$ESP_SDK_VER.zip
#rm esp8266_rtos_sdk-$ESP_SDK_VER.zip

###########

fi

######
# Install additional libraries from "https://github.com/$1"
#               URL path (i.e. $1 value)                                 Destination filename                           DestFolder  cache/nocache
# Libraries with explicit support for ESP8266
dlAndInstallLib "tzapu/WiFiManager/archive/0.12.zip"                     "WiFiManager-0.12-github.zip"                  "WiFiManager" "."
dlAndInstallLib "adafruit/RTClib/archive/1.2.0.zip"                      "adafruit-RTClib-1.2.0-github.zip"             "RTClib" "."
dlAndInstallLib "adafruit/Adafruit_SHT31/archive/1.0.0.zip"              "adafruit-SHT31-1.0.0-github.zip"              "Adafruit_SHT31" "."
dlAndInstallLib "adafruit/Adafruit_HDC1000_Library/archive/1.0.1.zip"    "adafruit-HDC1000-1.0.0-github.zip"            "Adafruit_HDC1000" "."
dlAndInstallLib "adafruit/Adafruit_BMP183_Library/archive/1.0.0.zip"     "adafruit-BMP183-1.0.0-github.zip"             "Adafruit_BMP183" "."
dlAndInstallLib "adafruit/Adafruit_MQTT_Library/archive/0.13.0.zip"      "adafruit-MQTT-0.13.0-github.zip"              "Adafruit_MQTT" "."
dlAndInstallLib "adafruit/MAX6675-library/archive/1.0.0.zip"             "adafruit-MAX6675-1.0.0-github.zip"            "max6675" "."
dlAndInstallLib "adafruit/ESP8266_Morse_Code/archive/master.zip"         "adafruit-Morse_Code-master-github.zip"        "MorseCode" "."
## forked below ## dlAndInstallLib "adafruit/DHT-sensor-library/archive/1.2.3.zip"          "adafruit-DHT_sensor_library-1.2.3-github.zip" "DHT" "."
## forked below ## dlAndInstallLib "adafruit/Adafruit_ADS1X15/archive/1.0.0.zip"            "adafruit-ADS1X15-1.0.0-github.zip"            "Adafruit_ADS1015" "."

# Libraries for Arduino and may also support ESP8266
dlAndInstallLib "adafruit/Adafruit_MMA8451_Library/archive/1.0.3.zip"    "adafruit-MMA8451-1.0.3-github.zip"            "Adafruit_MMA8451" "."
dlAndInstallLib "adafruit/Adafruit-MCP23008-library/archive/1.0.1.zip"   "adafruit-MCP23008-1.0.1-github.zip"           "Adafruit_MCP23008" "."
dlAndInstallLib "adafruit/Adafruit_Sensor/archive/1.0.2.zip"             "adaFruit-Sensor-1.0.2-github.zip"             "Adafruit_Sensor" "."
dlAndInstallLib "adafruit/Adafruit_SensorTester/archive/master.zip"      "adafruit-SensorTester-master-github.zip"      "Adafruit_SensorTester" "."
dlAndInstallLib "adafruit/Adafruit_MMA8451_Library/archive/1.0.3.zip"    "adafruit-MMA8451-1.0.3-github.zip"            "Adafruit_MMA8451" "."
dlAndInstallLib "adafruit/Adafruit_HTU21DF_Library/archive/1.0.0.zip"    "adafruit_HTU21DF-1.0.0-github.zip"            "Adafruit_HTU21DF" "."
dlAndInstallLib "Mr-rDy/Arduino-Temperature-Control-Library/archive/master.zip" "MyrDy-DallasTemperature-master-github.zip" "DallasTemperature" "."
dlAndInstallLib "sparkfun/BMP180_Breakout_Arduino_Library/archive/V_1.1.0.zip" "sparkfun_BMP180-1.1.1-github.zip"        "SFE_BMP180" "."
dlAndInstallLib "sparkfun/SHT15_Breakout/archive/HW_1.3_FW_1.1.zip"      "sparkfun_SHT15-HW1.3_FW1.1-github.zip"         "SHT1X" "."
## forked below ## dlAndInstallLib "sparkfun/SparkFun_HTU21D_Breakout_Arduino_Library/archive/V_1.1.1.zip" "sparkFun_HTU21D-1.1.1-github.zip" "SparkFunHTU21D" "."

# My forked libraries
dlAndInstallLib "intrepidor/OneWire/archive/master.zip"                  "intrepidor-OneWire-master-github.zip"         "OneWire" "nocache"
dlAndInstallLib "intrepidor/HTU21D_Arduino_Library/archive/master.zip"   "intrepidor-HTU21D-github.zip"                 "SparkFunHTU21D" "nocache"
dlAndInstallLib "intrepidor/DHT-sensor-library/archive/master.zip"       "intrepidor-DHT-github.zip"                    "DHT" "nocache"
dlAndInstallLib "intrepidor/Adafruit_ADS1X15/archive/master.zip"         "intrepidor-Adafruit_ADS1X15-github.zip"       "ADS1X15" "nocache"

# Software, but not libraries
dlAndInstallLib "adafruit/Raw-IR-decoder-for-Arduino/archive/master.zip" "adafruit-RawIRDecoder-master-github.zip"      "Raw-IR-decoder-for-Arduino" "."

# Non Software Libaries
dlAndInstallLib "adafruit/Adafruit-Eagle-Library/archive/master.zip"     "adafruit-Eagle-master-github.zip"             "Adafruit_Eagle" "."
dlAndInstallLib "sparkfun/SparkFun-Eagle-Libraries/archive/master.zip"   "sparkfun-Eagle-master-github.zip"             "Sparkfun_Eagle" "."

dlAndInstallLib "adafruit/Reference-Cards/archive/master.zip"            "adafruit-ReferenceCards-master-github.zip"    "Adafruit_ReferenceCards" "."


