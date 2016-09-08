# Makefile for esp8266/arduino
# Tested with version 1.6.5-r5

################################################################################################
####
####
TARGET = $(notdir $(realpath .))

BUILD_OUT = ./build.$(ARDUINO_VARIANT)

#GDB := -ggdb

# Choices are:
#	-O0 = No optimization. Use for debugging
#	-O1 = Optimizations that do not greatly affect compile time.
#	-O2 = O1 + Optimizations that do not involve code space/speed tradeoffs
#	-O3 = O2 + even more optimizations 
#	-Ofast = O3 + optimizations not valid for standard-compliant programs
#	-Os = All O2 optimizations that do not typically increase code size
#	-Og = All optimizations that do not interfere with debugging
OPTIMIZATION := -O2

# Choices are:
#   -g0 = negates -g. No debugging information
#   -g1 = minimal debug information, enough for backtraces, funtions, external variables. No local variables.
#   -g2 = standard debug information. Same as -g option.
#   -g3 = includes extra information, such as macro definitions and potentially macro expansion.
# NOTE: In case of duplicates, the last -g<n> option seen by the compilier is the one that gets used. 
DEBUGSYMBOLS := -g3

################################################################################################
####
# Get root directory
ARCH = $(shell uname)
ifeq ($(ARCH), Linux)
   ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
   EXEC_EXT = ""
else
   # The extensa tools cannot use cygwin paths, so convert /cygdrive/c/abc/... to c:/cygwin64/abc/...
   ROOT_DIR_RAW := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
   ROOT_DIR := $(shell cygpath -m $(ROOT_DIR_RAW))
   EXEC_EXT = ".exe"
endif

################################################################################################
####
#### USER STUFF ####
####

# sketch-specific
USER_LIBDIR ?= ./libraries

USRCDIRS = .
USER_SRC = $(wildcard $(addsuffix /*.c,$(USRCDIRS)))
USER_SSRC = $(wildcard $(addsuffix /*.S,$(USRCDIRS)))
USER_CXXSRC = $(wildcard $(addsuffix /*.cpp,$(USRCDIRS)))
USER_HSRC = $(wildcard $(addsuffix /*.h,$(USRCDIRS)))
USER_HPPSRC = $(wildcard $(addsuffix /*.hpp,$(USRCDIRS)))
LIB_INOSRC = $(wildcard $(addsuffix /*.ino,$(USRCDIRS)))

################################################################################################
####
#### ARDUINO and ESP8266
####

ARDUINO_HOME ?= $(ROOT_DIR)/arduino
EXTRA_LIBDIR ?= $(ROOT_DIR)/extra_libs
ESP_HOME = $(ARDUINO_HOME)/hardware/esp8266com/esp8266
ESP_CORES = $(ESP_HOME)/cores/$(ARDUINO_ARCH)
ESP_LWIP = $(ESP_HOME)/tools/sdk/lwip/include
GDBSTUB_LIBDIR ?= $(ESP_HOME)/libraries/GDBStub/src/internal

CORE_SSRC = $(wildcard $(ESP_CORES)/*.S)
CORE_SRC = $(wildcard $(ESP_CORES)/*.c)
CORE_SRC += $(wildcard $(ESP_CORES)/*/*.c)
CORE_CXXSRC = $(wildcard $(ESP_CORES)/*.cpp)
CORE_OBJS = $(addprefix $(BUILD_OUT)/core/, \
	$(notdir $(CORE_SSRC:.S=.S.o) $(CORE_SRC:.c=.c.o) $(CORE_CXXSRC:.cpp=.cpp.o)))

#GDB_SSRC = $(wildcard $(GDBSTUB_LIBDIR)/*.S)
#GDB_SRC = $(wildcard $(GDBSTUB_LIBDIR)/*.c)
#GDB_SRC += $(wildcard $(GDBSTUB_LIBDIR)/*/*.c)
#GDB_CXXSRC = $(wildcard $(GDBSTUB_LIBDIR)/*.cpp)
#GDB_OBJS = $(addprefix $(BUILD_OUT)/core/, \
#	$(notdir $(GDB_SSRC:.S=.S.o) $(GDB_SRC:.c=.c.o) $(GDB_CXXSRC:.cpp=.cpp.o)))
#GDB_INC  = $(GDBSTUB_LIBDIR)

CORE_INC = $(ESP_CORES) $(ESP_HOME)/variants/$(VARIANT) $(ESP_CORES)/spiffs $(ESP_LWIP) $(GDBSTUB_LIBDIR)

LOCAL_SRCS = $(USER_SRC) $(USER_SSRC) $(USER_CXXSRC) $(LIB_INOSRC) $(USER_HSRC) $(USER_HPPSRC)

################################################################################################
####
#### TOOLS
####

XTENSA_TOOLCHAIN ?= $(ROOT_DIR)/xtensa-lx106-elf/bin/

ESPRESSIF_SDK = $(ESP_HOME)/tools/sdk
ESPTOOL ?= $(ROOT_DIR)/bin/esptool$(EXEC_EXT)
ESPTOOLPY ?= /usr/local/bin/esptool.py
ESPOTA ?= $(ESP_HOME)/tools/espota.py
ESPTOOL_VERBOSE ?= -vv

CC := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-gcc
CXX := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-g++
AR := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-ar
LD := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-gcc
OBJDUMP := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-objdump
SIZE := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-size
CAT = /bin/cat$(EXEC_EXT)
SED = /bin/sed$(EXEC_EXT)
GAWK = /usr/bin/gawk$(EXEC_EXT)

################################################################################################
####
#### BOARD CONFIGURATION
####

ARDUINO_ARCH = esp8266
ARDUINO_BOARD ?= ESP8266_ESP12
ARDUINO_VARIANT ?= nodemcu
ARDUINO_VERSION ?= 10605
SERIAL_PORT ?= /dev/tty.nodemcu

BOARDS_TXT  = $(ESP_HOME)/boards.txt
PARSE_BOARD = $(ROOT_DIR)/bin/ard-parse-boards
PARSE_BOARD_OPTS = --boards_txt=$(BOARDS_TXT)
PARSE_BOARD_CMD = perl $(PARSE_BOARD) $(PARSE_BOARD_OPTS)

VARIANT = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) build.variant)
MCU   = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) build.mcu)
SERIAL_BAUD   = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) upload.speed)
F_CPU = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) build.f_cpu)
FLASH_SIZE = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) build.flash_size)
FLASH_MODE ?= $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) build.flash_mode)
#FLASH_MODE = dio
FLASH_FREQ = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) build.flash_freq)
UPLOAD_RESETMETHOD = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) upload.resetmethod)
UPLOAD_SPEED ?= $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) upload.speed)
# 115200 is the default; most hardware works with 230400, some with 460800, and some with 921600
#UPLOAD_SPEED = 115200
#UPLOAD_SPEED = 230400
#UPLOAD_SPEED = 460800
#UPLOAD_SPEED = 921600

################################################################################################
####
#### Autodetect defined User libraries
####

ifndef USER_LIBS
    USER_LIBS = $(sort $(filter $(notdir $(wildcard $(USER_LIBDIR)/*)), \
        $(shell $(SED) -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS))))
endif

ULIBDIRS = $(sort $(dir $(wildcard \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/*.c) \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/src/*.c) \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/src/*/*.c) \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/*.cpp) \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/src/*/*.cpp) \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/src/*.cpp))))
	## FIXME : Add .S source files to this list ##	

###############################################################################################
####
#### Auto detect included ESP8266-Arduino core libraries
####

ifndef EARDUINO_LIBS
    EARDUINO_LIBS = $(sort $(filter $(notdir $(wildcard $(ESP_HOME)/libraries/*)), \
        $(shell $(SED) -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS))))
endif

EALIBDIRS = $(sort $(dir $(wildcard \
	$(EARDUINO_LIBS:%=$(ESP_HOME)/libraries/%/*.c) \
	$(EARDUINO_LIBS:%=$(ESP_HOME)/libraries/%/src/*.c) \
	$(EARDUINO_LIBS:%=$(ESP_HOME)/libraries/%/src/*/*.c) \
	$(EARDUINO_LIBS:%=$(ESP_HOME)/libraries/%/*.h) \
	$(EARDUINO_LIBS:%=$(ESP_HOME)/libraries/%/src/*.h) \
	$(EARDUINO_LIBS:%=$(ESP_HOME)/libraries/%/src/*/*.h) \
	$(EARDUINO_LIBS:%=$(ESP_HOME)/libraries/%/*.cpp) \
	$(EARDUINO_LIBS:%=$(ESP_HOME)/libraries/%/src/*/*.cpp) \
	$(EARDUINO_LIBS:%=$(ESP_HOME)/libraries/%/src/*.cpp) \
	$(EARDUINO_LIBS:%=$(GDBSTUB_LIBDIR)/%/*.c) \
	$(EARDUINO_LIBS:%=$(GDBSTUB_LIBDIR)/%/src/*.c) \
	$(EARDUINO_LIBS:%=$(GDBSTUB_LIBDIR)/%/src/*/*.c) \
	$(EARDUINO_LIBS:%=$(GDBSTUB_LIBDIR)/%/*.h) \
	$(EARDUINO_LIBS:%=$(GDBSTUB_LIBDIR)/%/src/*.h) \
	$(EARDUINO_LIBS:%=$(GDBSTUB_LIBDIR)/%/src/*/*.h) \
	$(EARDUINO_LIBS:%=$(GDBSTUB_LIBDIR)/%/*.cpp) \
	$(EARDUINO_LIBS:%=$(GDBSTUB_LIBDIR)/%/src/*/*.cpp) \
	$(EARDUINO_LIBS:%=$(GDBSTUB_LIBDIR)/%/src/*.cpp))))
	## FIXME : Add .S source files to this list ##

###############################################################################################
####
#### Auto detect included Arduino core libraries
####

#ifndef ARDUINO_LIBS
#    ARDUINO_LIBS = $(sort $(filter $(notdir $(wildcard $(ARDUINO_HOME)/libraries/*)), \
#        $(shell $(SED) -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS))))
#endif
#
#ALIBDIRS = $(sort $(dir $(wildcard \
#	$(ARDUINO_LIBS:%=$(ARDUINO_HOME)/libraries/%/*.c) \
#	$(ARDUINO_LIBS:%=$(ARDUINO_HOME)/libraries/%/*.cpp) \
#	$(ARDUINO_LIBS:%=$(ARDUINO_HOME)/libraries/%/src/*.c) \
#	$(ARDUINO_LIBS:%=$(ARDUINO_HOME)/libraries/%/src/*.cpp))))

###############################################################################################
####
#### Auto detect included Additional/Extra libraries
####	

ifndef EXTRA_LIBS
    # automatically determine included libraries
    EXTRA_LIBS = $(sort $(filter $(notdir $(wildcard $(EXTRA_LIBDIR)/*)), \
        $(shell $(SED) -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS))))
endif

ELIBDIRS = $(sort $(dir $(wildcard \
	$(EXTRA_LIBS:%=$(EXTRA_LIBDIR)/%/*.c) \
	$(EXTRA_LIBS:%=$(EXTRA_LIBDIR)/%/src/*.c) \
	$(EXTRA_LIBS:%=$(EXTRA_LIBDIR)/%/src/*/*.c) \
	$(EXTRA_LIBS:%=$(EXTRA_LIBDIR)/%/*.cpp) \
	$(EXTRA_LIBS:%=$(EXTRA_LIBDIR)/%/src/*/*.cpp) \
	$(EXTRA_LIBS:%=$(EXTRA_LIBDIR)/%/src/*.cpp))))
	## FIXME : Add .S source files to this list ##

###############################################################################################
####
#### 
####	
	
# all sources
LIB_SRC = $(wildcard $(addsuffix /*.c,$(ULIBDIRS))) \
	$(wildcard $(addsuffix /*.c,$(ALIBDIRS))) \
	$(wildcard $(addsuffix /*.c,$(ELIBDIRS))) \
	$(wildcard $(addsuffix /*.c,$(EALIBDIRS)))
LIB_CXXSRC = $(wildcard $(addsuffix /*.cpp,$(ULIBDIRS))) \
	$(wildcard $(addsuffix /*.cpp,$(ALIBDIRS))) \
	$(wildcard $(addsuffix /*.cpp,$(ELIBDIRS))) \
	$(wildcard $(addsuffix /*.cpp,$(EALIBDIRS)))
	## FIXME : Add .S source files to this list ##	

# object files
OBJ_FILES = $(addprefix $(BUILD_OUT)/,$(notdir \
	$(LIB_SRC:.c=.c.o) \
	$(LIB_CXXSRC:.cpp=.cpp.o) \
	$(LIB_INOSRC:.ino=.ino.o) \
	$(USER_SRC:.c=.c.o) \
	$(USER_SSRC:.S=.S.o) \
	$(USER_CXXSRC:.cpp=.cpp.o)))

# includes
INCLUDES = $(CORE_INC:%=-I%) $(ALIBDIRS:%=-I%) $(EALIBDIRS:%=-I%) $(ULIBDIRS:%=-I%) $(ELIBDIRS:%=-I%)

VPATH = . $(CORE_INC) $(ALIBDIRS) $(EALIBDIRS) $(ULIBDIRS) $(ELIBDIRS)

################################################################################################
####
#### FLAGS
####

DEFINES = $(USER_DEFINE) -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ \
	-DF_CPU=$(F_CPU) -DARDUINO=$(ARDUINO_VERSION) \
	-DARDUINO_$(ARDUINO_BOARD) -DESP8266 \
	-DARDUINO_ARCH_$(shell echo "$(ARDUINO_ARCH)" | tr '[:lower:]' '[:upper:]') \
	-I$(ESPRESSIF_SDK)/include

ASFLAGS = -c -g -x assembler-with-cpp -MMD $(DEFINES)

CFLAGS_EXCLUDE_FOR_CLANG = -mlongcalls
CFLAGS = -c \
	-Wpointer-arith \
	-Wno-implicit-function-declaration \
	-Wl,-EL \
	-fno-inline-functions \
	-nostdlib \
	-mtext-section-literals \
	-falign-functions=4 \
	-MMD \
	-std=gnu99 \
	-ffunction-sections \
	-fdata-sections \
	$(CFLAGS_EXCLUDE_FOR_CLANG) \
	$(OPTIMIZATION) $(DEBUGSYMBOLS) $(DEBUG) $(GDB)

CXXFLAGS = -c \
	-mlongcalls \
	-mtext-section-literals \
	-fno-exceptions \
	-fno-rtti \
	-falign-functions=4 \
	-std=c++11 \
	-MMD \
	$(OPTIMIZATION) $(DEBUGSYMBOLS) $(DEBUG) $(GDB)

LDFLAGS = -nostdlib \
	-Wl,--gc-sections \
	-Wl,--no-check-sections \
	-u call_user_start \
	-Wl,-static \
	-Wl,-wrap,system_restart_local \
	-Wl,-wrap,register_chipv6_phy

################################################################################################
####
#### RULES
####

.PHONY: all arduino dirs clean upload

all: show_variables dirs core libs bin size 

help:
	@echo "make debug"
	@echo "make show_variables"
	@echo "make dirs"
	@echo "make clean"
	@echo "make core"
	@echo "make libs"
	@echo "make bin"
	@echo "make size"
	@echo "make sizeall"
	@echo "make lint"
	@echo "make list"
	@echo "make upload"
	@echo "make eraseFlash"
	@echo "make dumpROM"
	@echo "make read_flash_id"
	@echo "make read_chip_id"				
	@echo "make read_mac"
	@echo "make term"
	@echo "make print-%"
	@echo "make printall"

debug: 
	make DEBUG="-Og -ggdb" GDB=-DGDBSTUB all

show_variables:
	$(info [ARDUINO_LIBS] : $(ARDUINO_LIBS))
	$(info [EARDUINO_LIBS] : $(EARDUINO_LIBS))
	$(info [USER_LIBS] : $(USER_LIBS))
	$(info [EXTRA_LIBS] : $(EXTRA_LIBS))

dirs:
	@mkdir -p $(BUILD_OUT)
	@mkdir -p $(BUILD_OUT)/core
	@mkdir -p $(BUILD_OUT)/spiffs
	@mkdir -p $(BUILD_OUT)/libb64
	@mkdir -p $(BUILD_OUT)/umm_malloc

clean:
	rm -rf $(BUILD_OUT)

core: dirs $(BUILD_OUT)/core/core.a 
#$(BUILD_OUT)/core/gdbstub.a

libs: dirs $(OBJ_FILES)

bin: $(BUILD_OUT)/$(TARGET).bin

$(BUILD_OUT)/core/%.o: $(ESP_CORES)/%.c
	$(CC) $(DEFINES) $(CORE_INC:%=-I%) $(CFLAGS) -o $@ $<

$(BUILD_OUT)/spiffs/%.o: $(ESP_CORES)/spiffs/%.c
	$(CC) $(DEFINES) $(CORE_INC:%=-I%) $(CFLAGS) -o $@ $<

$(BUILD_OUT)/core/%.c.o: $(ESP_CORES)/libb64/%.c
	$(CC) $(DEFINES) $(CORE_INC:%=-I%) $(CFLAGS) -o $@ $<

$(BUILD_OUT)/core/%.c.o: $(ESP_CORES)/umm_malloc/%.c
	$(CC) $(DEFINES) $(CORE_INC:%=-I%) $(CFLAGS) -o $@ $<
	
$(BUILD_OUT)/core/%.o: $(ESP_CORES)/%.cpp
	$(CXX) $(DEFINES) $(CORE_INC:%=-I%) $(CXXFLAGS) -o $@ $<

$(BUILD_OUT)/core/%.S.o: $(ESP_CORES)/%.S
	$(CC) $(ASFLAGS) -o $@ $<
	
$(BUILD_OUT)/core/core.a: $(CORE_OBJS)
	$(AR) cru $@ $(CORE_OBJS)

#$(BUILD_OUT)/core/gdbstub.a: $(GDB_OBJS)
#	$(AR) cru $@ $(GDB_OBJS)
#
#$(BUILD_OUT)/core/%.S.o: $(GDB_OBJS)/%.S
#	$(CC) $(ASFLAGS) -o $@ $<
	
$(BUILD_OUT)/core/%.c.o: %.c
	$(CC) $(DEFINES) $(CFLAGS) $(INCLUDES) -o $@ $<

$(BUILD_OUT)/core/%.cpp.o: %.cpp
	$(CXX) $(DEFINES) $(CXXFLAGS) $(INCLUDES) $< -o $@

$(BUILD_OUT)/%.c.o: %.c
	$(CC) $(DEFINES) $(CFLAGS) $(INCLUDES) -o $@ $<

$(BUILD_OUT)/%.S.o: %.S
	$(CC) $(DEFINES) $(ASFLAGS) $(INCLUDES) -o $@ $<

$(BUILD_OUT)/%.ino.o: %.ino
	$(CXX) -x c++ $(DEFINES) $(CXXFLAGS) $(INCLUDES) $< -o $@

$(BUILD_OUT)/%.cpp.o: %.cpp
	$(CXX) $(DEFINES) $(CXXFLAGS) $(INCLUDES) $< -o $@

# ultimately, use our own ld scripts ...
$(BUILD_OUT)/$(TARGET).elf: core libs
	$(LD) $(LDFLAGS) -L$(ESPRESSIF_SDK)/lib \
		-L$(ESPRESSIF_SDK)/ld -T$(ESPRESSIF_SDK)/ld/eagle.flash.4m.ld \
		-o $@ -Wl,--start-group $(OBJ_FILES) $(BUILD_OUT)/core/core.a \
		-lm -lgcc -lhal -lphy -lnet80211 -llwip -lwpa -lmain -lpp -lsmartconfig \
		-lwps -lcrypto \
		-Wl,--end-group -L$(BUILD_OUT)

size: $(BUILD_OUT)/$(TARGET).elf
	$(SIZE) -A $(BUILD_OUT)/$(TARGET).elf | \
		grep -E '^(Total|\.text|\.data|\.rodata|\.bss|\.comment|\.irom0\.text|)\s+([0-9]+).*'

sizeall: $(BUILD_OUT)/$(TARGET).elf
	$(SIZE) -A $(BUILD_OUT)/$(TARGET).elf

lint: _LINT.TMP 
	./lint *.c*

lst:
	$(OBJDUMP) \
	--debugging \
	--demangle \
	--headers \
	--file-headers \
	--line-numbers \
	--disassemble \
	--source \
	--syms \
	--all-headers \
	--wide \
	$(BUILD_OUT)/$(TARGET).elf > $(BUILD_OUT)/$(TARGET).lst

$(BUILD_OUT)/$(TARGET).bin: $(BUILD_OUT)/$(TARGET).elf
	echo "Building BIN ..."
	$(ESPTOOL) -eo $(ESP_HOME)/bootloaders/eboot/eboot.elf -bo $(BUILD_OUT)/$(TARGET).bin \
		-bm $(FLASH_MODE) -bf $(FLASH_FREQ) -bz $(FLASH_SIZE) \
		-bs .text -bp 4096 -ec -eo $(BUILD_OUT)/$(TARGET).elf -bs .irom0.text -bs .text -bs .data -bs .rodata -bc -ec

upload: $(BUILD_OUT)/$(TARGET).bin size
	$(ESPTOOL) $(ESPTOOL_VERBOSE) \
		-cd $(UPLOAD_RESETMETHOD) \
		-cb $(UPLOAD_SPEED) \
		-cp $(SERIAL_PORT) \
		-ca 0x00000 \
		-cf $(BUILD_OUT)/$(TARGET).bin

eraseflash:
	$(ESPTOOL) $(ESPTOOL_VERBOSE) \
		-cd $(UPLOAD_RESETMETHOD) \
		-cb $(UPLOAD_SPEED) \
		-cp $(SERIAL_PORT) \
		-ca 0x00000 \
		-cf blank_1MB.bin

# Internal 64KB ROM resides at 0x40000000
dumpROM:
	echo "Dumping ESP8266 64KB ROM to iram0.bin"
	$(ESPTOOLPY) \
	-fs $(FLASH_SIZE) \
	-ff $(FLASH_FREQ) \
	-fm $(FLASH_MODE) \
	--port $(SERIAL_PORT) \
	--baud $(SERIAL_BAUD) \
	dump_mem 0x40000000 65536 iram0.bin

read_mac: 
	$(ESPTOOLPY) \
	--port $(SERIAL_PORT) \
	--baud $(SERIAL_BAUD) \
	read_mac

read_flash_id:
	$(ESPTOOLPY) \
	--port $(SERIAL_PORT) \
	--baud $(SERIAL_BAUD) \
	flash_id

read_chip_id:
	$(ESPTOOLPY) \
	--port $(SERIAL_PORT) \
	--baud $(SERIAL_BAUD) \
	chip_id

#ota: $(BUILD_OUT)/$(TARGET).bin
#	$(ESPOTA) 192.168.1.184 8266 $(BUILD_OUT)/$(TARGET).bin

term:
	minicom -D $(SERIAL_PORT) -b $(UPLOAD_SPEED)
#	cu -l $(SERIAL_PORT) -s $(SERIAL_BAUD)

print-%: ; @echo $* = $($*)

-include $(OBJ_FILES:.o=.d)

printall:
	@echo ""
	@echo "### DIRECTORIES ###"
	@echo "TARGET=$(TARGET)"
	@echo "BUILD_OUT=$(BUILD_OUT)"
	@echo ""
	@echo "ROOT_DIR=$(ROOT_DIR)"
	@echo "ARDUINO_HOME=$(ARDUINO_HOME)"
	@echo "ESP_HOME=$(ESP_HOME)"
	@echo "XTENSA_TOOLCHAIN=$(XTENSA_TOOLCHAIN)"
	@echo "ESPRESSIF_SDK=$(ESPRESSIF_SDK)"
	@echo "ESP_CORES=$(ESP_CORES)"
	@echo ""
	@echo "EARDUINO_HOME=$(EARDUINO_HOME)"
	@echo "EXTRA_LIBDIR=$(EXTRA_LIBDIR)"
	@echo "USER_LIBDIR=$(USER_LIBDIR)"
	@echo ""
	@echo "ARDUINO_LIBS=$(ARDUINO_LIBS)"
	@echo "EXTRA_LIBS=$(EXTRA_LIBS)"
	@echo "USER_LIBS=$(USER_LIBS)"
	@echo ""
	@echo "ELIBDIRS=$(ELIBDIRS)"
	@echo "ULIBDIRS=$(ULIBDIRS)"
	@echo "ALIBDIRS=$(ALIBDIRS)"
	@echo "EALIBDIRS=$(EALIBDIRS)"
	@echo ""
	@echo "### FILES AND TOOLS ###"
	@echo "BOARDS_TXT=$(BOARDS_TXT)"
	@echo "PARSE_BOARD=$(PARSE_BOARD)"0
	@echo "ESPTOOL=$(ESPTOOL)"
	@echo "ESPOTA=$(ESPOTA)"
	@echo "AR=$(AR)"
	@echo "CAT=$(CAT)"
	@echo "CC=$(CC)"
	@echo "CXX=$(CXX)"
	@echo "LD=$(LD)"
	@echo "OBJDUMP=$(OBJDUMP)"
	@echo "SIZE=$(SIZE)"
	@echo ""
	@echo "### ATTRIBUTES ###"
	@echo "ARDUINO_ARCH=$(ARDUINO_ARCH)"
	@echo "ARDUINO_BOARD=$(ARDUINO_BOARD)"
	@echo "ARDUINO_VARIANT=$(ARDUINO_VARIANT)"
	@echo "ARDUINO_VERSION=$(ARDUINO_VERSION)"
	@echo "SERIAL_PORT=$(SERIAL_PORT)"
	@echo "VARIANT=$(VARIANT)"
	@echo "MCU=$(MCU)"
	@echo "SERIAL_BAUD=$(SERIAL_BAUD)"
	@echo "F_CPU=$(F_CPU)"
	@echo "FLASH_SIZE=$(FLASH_SIZE)"
	@echo "FLASH_MODE=$(FLASH_MODE)"
	@echo "FLASH_FREQ=$(FLASH_FREQ)"
	@echo "UPLOAD_RESETMETHOD=$(UPLOAD_RESETMETHOD)"
	@echo "UPLOAD_SPEED=$(UPLOAD_SPEED)"
	@echo ""
	@echo "### ARGUMENTS AND FLAGS ###"
	@echo "PARSE_BOARD_OPTS=$(PARSE_BOARD_OPTS)"
	@echo "PARSE_BOARD_CMD=$(PARSE_BOARD_CMD)"
	@echo "ASFLAGS=$(ASFLAGS)"
	@echo "CFLAGS=$(CFLAGS)"
	@echo "CXXFLAGS=$(CXXFLAGS)"
	@echo "LDFLAGS=$(LDFLAGS)"
	@echo "DEFINES=$(DEFINES)"
	@echo "OPTIMIZATION=$(OPTIMIZATION)"
	@echo "DEBUGSYMBOLS=$(DEBUGSYMBOLS)"		
	@echo ""
	@echo "### LISTS OF DIRECTORIES ###"
	@echo "CORE_INC=$(CORE_INC)"
	@echo "INCLUDES=$(INCLUDES)"
	@echo "USRCDIRS=$(USRCDIRS)"
	@echo "VPATH=$(VPATH)"
#	@echo "GDB_INC=$(GDB_INC)"
	@echo ""
	@echo "### LISTS OF FILES ###"
	@echo "CORE_SSRC=$(CORE_SSRC)"
	@echo "CORE_SRC=$(CORE_SRC)"
	@echo "CORE_CXXSRC=$(CORE_CXXSRC)"
	@echo "CORE_OBJS=$(CORE_OBJS)"
#	@echo ""
#	@echo "GDB_SSRC=$(GDB_SSRC)"
#	@echo "GDB_SRC=$(GDB_SRC)"
#	@echo "GDB_CXXSRC=$(GDB_CXXSRC)"
#	@echo "GDB_OBJS=$(GDB_OBJS)"
	@echo ""
	@echo "LOCAL_SRCS=$(LOCAL_SRCS)"
	@echo "OBJ_FILES=$(OBJ_FILES)"
	@echo "LIB_CXXSRC=$(LIB_CXXSRC)"
	@echo "LIB_INOSRC=$(LIB_INOSRC)"
	@echo "LIB_SRC=$(LIB_SRC)"
	@echo ""
	@echo "USER_CXXSRC=$(USER_CXXSRC)"
	@echo "USER_HPPSRC=$(USER_HPPSRC)"
	@echo "USER_HSRC=$(USER_HSRC)"
	@echo "USER_SRC=$(USER_SRC)"
	@echo "USER_SSRC=$(USER_SSRC)"
	@echo ""
	@echo "DEBUG=$(DEBUG)"

