# Be sure to chmod +x install-cygwin.sh before running the script.
echo "This script expects the cygdrive mount point to have the noacl attribute set in /etc/fstab"

declare ARDUINO_VER=arduino-1.6.5-r5
declare ESP8266_VER=esp8266-2.0.0-rc2

# save anything that is downloaded for faster reinstalls
declare DOWNLOAD_CACHE=../download
mkdir $DOWNLOAD_CACHE

# Get MKSPIFFS Tool
cp -np $DOWNLOAD_CACHE/mkspiffs-0.1.2-windows.zip .
wget --no-clobber --no-check-certificate http://github.com/igrr/mkspiffs/releases/download/0.1.2/mkspiffs-0.1.2-windows.zip
unzip mkspiffs-0.1.2-windows.zip
mv mkspiffs-0.1.2-windows/mkspiffs.exe bin
rmdir mkspiffs-0.1.2-windows
mv mkspiffs-0.1.2-windows.zip $DOWNLOAD_CACHE
chmod +x bin/mkspiffs.exe

# Get Xtensa GCC Compiler
cp -np $DOWNLOAD_CACHE/win32-xtensa-lx106-elf-gb404fb9-2.tar.gz .
wget --no-clobber --no-check-certificate http://arduino.esp8266.com/win32-xtensa-lx106-elf-gb404fb9-2.tar.gz
tar xvfz win32-xtensa-lx106-elf-gb404fb9-2.tar.gz
mv win32-xtensa-lx106-elf-gb404fb9-2.tar.gz $DOWNLOAD_CACHE

# Get ESPTOOL
cp -np $DOWNLOAD_CACHE/esptool-0.4.6-win32.zip .
wget --no-clobber --no-check-certificate https://github.com/igrr/esptool-ck/releases/download/0.4.6/esptool-0.4.6-win32.zip
unzip esptool-0.4.6-win32.zip
mv esptool-0.4.6-win32/esptool.exe bin
rmdir esptool-0.4.6-win32
mv esptool-0.4.6-win32.zip $DOWNLOAD_CACHE
chmod +x bin/esptool.exe

# Get Arduino IDE
cp -p $DOWNLOAD_CACHE/$ARDUINO_VER-windows.zip $ARDUINO_VER-windows.zip
wget --no-clobber --no-check-certificate http://arduino.cc/download.php?f=/$ARDUINO_VER-windows.zip -O $ARDUINO_VER-windows.zip 
unzip $ARDUINO_VER-windows.zip
mv $ARDUINO_VER-windows.zip $DOWNLOAD_CACHE

# Copy ESP8266_Arduino Libraries
mkdir -p $ARDUINO_VER/hardware/esp8266com
cp -rp $ESP8266_VER $ARDUINO_VER/hardware/esp8266com/esp8266

















































