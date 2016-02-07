mkdir _attic
# MKSPIFFS Tool
cp -np _attic/mkspiffs-0.1.2-windows.zip .
wget --no-clobber --no-check-certificate http://github.com/igrr/mkspiffs/releases/download/0.1.2/mkspiffs-0.1.2-windows.zip
unzip mkspiffs-0.1.2-windows.zip
mv mkspiffs-0.1.2-windows/mkspiffs.exe bin
rmdir mkspiffs-0.1.2-windows
mv mkspiffs-0.1.2-windows.zip _attic
chmod +x bin/mkspiffs.exe

# Xtensa GCC Compiler
cp -np _attic/win32-xtensa-lx106-elf-gb404fb9-2.tar.gz .
wget --no-clobber --no-check-certificate http://arduino.esp8266.com/win32-xtensa-lx106-elf-gb404fb9-2.tar.gz
tar xvfz win32-xtensa-lx106-elf-gb404fb9-2.tar.gz
mv win32-xtensa-lx106-elf-gb404fb9-2.tar.gz _attic

# ESPTOOL
cp -np _attic/esptool-0.4.6-win32.zip .
wget --no-clobber --no-check-certificate https://github.com/igrr/esptool-ck/releases/download/0.4.6/esptool-0.4.6-win32.zip
unzip esptool-0.4.6-win32.zip
mv esptool-0.4.6-win32/esptool.exe bin
rmdir esptool-0.4.6-win32
mv esptool-0.4.6-win32.zip _attic
chmod +x bin/esptool.exe

 
#wget http://arduino.esp8266.com/linux64-xtensa-lx106-elf-gb404fb9.tar.gz && tar xvfz linux64-xtensa-lx106-elf-gb404fb9.tar.gz && rm linux64-xtensa-lx106-elf-gb404fb9.tar.gz
