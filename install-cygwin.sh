# Be sure to chmod +x install-cygwin.sh before running the script.
echo "This script expects the cygdrive mount point to have the noacl attribute set in /etc/fstab"

declare ARDUINO_VER=1.6.5-r5
declare ESP8266_VER=2.0.0
declare MKSPIFFS_VER=0.1.2
declare ESPTOOL_VER=0.4.6

# save anything that is downloaded for faster reinstalls
declare DOWNLOAD_CACHE=../download
mkdir -p $DOWNLOAD_CACHE

# Get MKSPIFFS Tool
echo "Downloading MKSPIFFS Tool " $MKSPIFFS_VER " ..."
cp -p $DOWNLOAD_CACHE/mkspiffs-$MKSPIFFS_VER-windows.zip .
wget --no-clobber --no-check-certificate https://github.com/igrr/mkspiffs/releases/download/$MKSPIFFS_VER/mkspiffs-$MKSPIFFS_VER-windows.zip
cp -p mkspiffs-$MKSPIFFS_VER-windows.zip $DOWNLOAD_CACHE
echo "Uncompressing MKSPIFFS Tool ..."
unzip -q mkspiffs-$MKSPIFFS_VER-windows.zip
mv mkspiffs-$MKSPIFFS_VER-windows/mkspiffs.exe bin
chmod +x bin/mkspiffs.exe
rmdir mkspiffs-$MKSPIFFS_VER-windows
rm mkspiffs-$MKSPIFFS_VER-windows.zip

# Get Xtensa GCC Compiler
echo "Downloading Xtensa GCC Compiler ..."
cp -p $DOWNLOAD_CACHE/win32-xtensa-lx106-elf-gb404fb9-2.tar.gz .
wget --no-clobber --no-check-certificate http://arduino.esp8266.com/win32-xtensa-lx106-elf-gb404fb9-2.tar.gz
cp -p win32-xtensa-lx106-elf-gb404fb9-2.tar.gz $DOWNLOAD_CACHE
echo "Uncompressing Xtensa GCC Compiler ..."
tar xfz win32-xtensa-lx106-elf-gb404fb9-2.tar.gz
rm win32-xtensa-lx106-elf-gb404fb9-2.tar.gz

# Get ESPTOOL
echo "Downloading ESPTOOL " $ESPTOOL_VER " ..."
cp -p $DOWNLOAD_CACHE/esptool-$ESPTOOL_VER-win32.zip .
wget --no-clobber --no-check-certificate https://github.com/igrr/esptool-ck/releases/download/$ESPTOOL_VER/esptool-$ESPTOOL_VER-win32.zip
cp -p esptool-$ESPTOOL_VER-win32.zip $DOWNLOAD_CACHE
echo "Uncompressing ESPTOOL ..."
unzip -q esptool-$ESPTOOL_VER-win32.zip
mv esptool-$ESPTOOL_VER-win32/esptool.exe bin
chmod +x bin/esptool.exe
rmdir esptool-$ESPTOOL_VER-win32
rm esptool-$ESPTOOL_VER-win32.zip

# Get Arduino IDE
echo "Downloading Arduino IDE " $ARDUINO_VER " ..."
cp -p $DOWNLOAD_CACHE/arduino-$ARDUINO_VER-windows.zip arduino-$ARDUINO_VER-windows.zip
wget --no-clobber --no-check-certificate http://arduino.cc/download.php?f=/arduino-$ARDUINO_VER-windows.zip -O arduino-$ARDUINO_VER-windows.zip 
cp -p arduino-$ARDUINO_VER-windows.zip $DOWNLOAD_CACHE/arduino-$ARDUINO_VER-windows.zip
echo "Uncompressing Arduino IDE ..."
unzip -q arduino-$ARDUINO_VER-windows.zip
rm arduino-$ARDUINO_VER-windows.zip

# Get Arduino core for ESP8266 chip
echo "Downloading Arduino core for ESP8266 " $ESP8266_VER " ..."
cp -np $DOWNLOAD_CACHE/esp8266-$ESP8266_VER.zip .
wget --no-clobber --no-check-certificate https://github.com/esp8266/Arduino/releases/download/$ESP8266_VER/esp8266-$ESP8266_VER.zip
cp -np esp8266-$ESP8266_VER.zip $DOWNLOAD_CACHE
echo "Uncompressing Arduino core for ESP8266 ..."
unzip -q esp8266-$ESP8266_VER.zip
rm esp8266-$ESP8266_VER.zip

# Copy ESP8266_Arduino Libraries
echo "Copying Arduino ESP8266 core to Arduino IDE ..."
mkdir -p arduino-$ARDUINO_VER/hardware/esp8266com
mv esp8266-$ESP8266_VER arduino-$ARDUINO_VER/hardware/esp8266com/esp8266

#
echo "All done."
















































