# Makefile for esp8266/arduino
# Tested with version 1.6.5-r5

TARGET = $(notdir $(realpath .))
ROOT_DIR_CYGWIN := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
# The extensa tools cannot use cygwin paths, so convert /cygdrive/c/abc/... to c:/cygwin64/abc/...
ROOT_DIR := $(shell cygpath -m $(ROOT_DIR_CYGWIN))

################################################################################################
####
#### USER STUFF ####
####

# sketch-specific
USER_LIBDIR ?= ./libraries

USRCDIRS = .
USER_SRC = $(wildcard $(addsuffix /*.c,$(USRCDIRS)))
USER_CXXSRC = $(wildcard $(addsuffix /*.cpp,$(USRCDIRS)))
USER_HSRC = $(wildcard $(addsuffix /*.h,$(USRCDIRS)))
USER_HPPSRC = $(wildcard $(addsuffix /*.hpp,$(USRCDIRS)))
LIB_INOSRC = $(wildcard $(addsuffix /*.ino,$(USRCDIRS)))

################################################################################################
####
#### ARDUINO and ESP8266
####

ARDUINO_HOME ?= $(ROOT_DIR)/arduino-1.6.5-r5
ESP_HOME = $(ARDUINO_HOME)/hardware/esp8266com/esp8266
ESP_CORES = $(ESP_HOME)/cores/$(ARDUINO_ARCH)

CORE_SSRC = $(wildcard $(ESP_CORES)/*.S)
CORE_SRC = $(wildcard $(ESP_CORES)/*.c)
CORE_SRC += $(wildcard $(ESP_CORES)/*/*.c)
CORE_CXXSRC = $(wildcard $(ESP_CORES)/*.cpp)
CORE_OBJS = $(addprefix $(BUILD_OUT)/core/, \
	$(notdir $(CORE_SSRC:.S=.S.o) $(CORE_SRC:.c=.c.o) $(CORE_CXXSRC:.cpp=.cpp.o)))

CORE_INC = $(ESP_CORES) $(ESP_HOME)/variants/$(VARIANT) $(ESP_CORES)/spiffs

################################################################################################
####
#### TOOLS
####

XTENSA_TOOLCHAIN ?= $(ROOT_DIR)/xtensa-lx106-elf/bin/

ESPRESSIF_SDK = $(ESP_HOME)/tools/sdk
ESPTOOL ?= $(ROOT_DIR)/bin/esptool.exe
ESPOTA ?= $(ESP_HOME)/tools/espota.py
#ESPTOOL_VERBOSE ?= -vv

CC := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-gcc
CXX := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-g++
AR := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-ar
LD := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-gcc
OBJDUMP := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-objdump
SIZE := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-size
CAT	= cat.exe
SED = sed.exe

# xtensa-lx106-elf-addr2line.exe
# xtensa-lx106-elf-ar.exe
# xtensa-lx106-elf-as.exe
# xtensa-lx106-elf-c++.exe
# xtensa-lx106-elf-c++filt.exe
# xtensa-lx106-elf-cpp.exe
# xtensa-lx106-elf-elfedit.exe
# xtensa-lx106-elf-g++.exe
# xtensa-lx106-elf-gcc.exe
# xtensa-lx106-elf-gcc-4.8.2.exe
# xtensa-lx106-elf-gcc-ar.exe
# xtensa-lx106-elf-gcc-nm.exe
# xtensa-lx106-elf-gcc-ranlib.exe
# xtensa-lx106-elf-gcov.exe
# xtensa-lx106-elf-gprof.exe
# xtensa-lx106-elf-ld.bfd.exe
# xtensa-lx106-elf-ld.exe
# xtensa-lx106-elf-nm.exe
# xtensa-lx106-elf-objcopy.exe
# xtensa-lx106-elf-objdump.exe
# xtensa-lx106-elf-ranlib.exe
# xtensa-lx106-elf-readelf.exe
# xtensa-lx106-elf-size.exe
# xtensa-lx106-elf-strings.exe
# xtensa-lx106-elf-strip.exe

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
FLASH_MODE = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) build.flash_mode)
FLASH_FREQ = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) build.flash_freq)
UPLOAD_RESETMETHOD = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) upload.resetmethod)
UPLOAD_SPEED = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) upload.speed)

################################################################################################
####
#### INPUTS FILES AND FILE LISTS
####

BUILD_OUT = ./build.$(ARDUINO_VARIANT)

#autodetect arduino libs and user libs
LOCAL_SRCS = $(USER_SRC) $(USER_CXXSRC) $(LIB_INOSRC) $(USER_HSRC) $(USER_HPPSRC)
ifndef USER_LIBS
    # automatically determine included user libraries
    USER_LIBS = $(sort $(filter $(notdir $(wildcard $(USER_LIBDIR)/*)), \
        $(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS))))
endif

# user libraries and sketch code
ULIBDIRS = $(sort $(dir $(wildcard \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/*.c) \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/src/*.c) \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/src/*/*.c) \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/*.cpp) \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/src/*/*.cpp) \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/src/*.cpp))))

ifndef ARDUINO_LIBS
    # automatically determine included libraries
    ARDUINO_LIBS = $(sort $(filter $(notdir $(wildcard $(ESP_HOME)/libraries/*)), \
        $(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS))))
endif

# arduino libraries
ALIBDIRS = $(sort $(dir $(wildcard \
	$(ARDUINO_LIBS:%=$(ESP_HOME)/libraries/%/*.c) \
	$(ARDUINO_LIBS:%=$(ESP_HOME)/libraries/%/*.cpp) \
	$(ARDUINO_LIBS:%=$(ESP_HOME)/libraries/%/src/*.c) \
	$(ARDUINO_LIBS:%=$(ESP_HOME)/libraries/%/src/*.cpp))))

# all sources
LIB_SRC = $(wildcard $(addsuffix /*.c,$(ULIBDIRS))) $(wildcard $(addsuffix /*.c,$(ALIBDIRS)))
LIB_CXXSRC = $(wildcard $(addsuffix /*.cpp,$(ULIBDIRS))) $(wildcard $(addsuffix /*.cpp,$(ALIBDIRS)))

# object files
OBJ_FILES = $(addprefix $(BUILD_OUT)/,$(notdir $(LIB_SRC:.c=.c.o) $(LIB_CXXSRC:.cpp=.cpp.o) $(LIB_INOSRC:.ino=.ino.o) $(USER_SRC:.c=.c.o) $(USER_CXXSRC:.cpp=.cpp.o)))

# includes
INCLUDES = $(CORE_INC:%=-I%) $(ALIBDIRS:%=-I%) $(ULIBDIRS:%=-I%)

VPATH = . $(CORE_INC) $(ALIBDIRS) $(ULIBDIRS)

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

CFLAGS = -c -Os -Wpointer-arith -Wno-implicit-function-declaration -Wl,-EL \
	-fno-inline-functions -nostdlib -mlongcalls -mtext-section-literals \
	-falign-functions=4 -MMD -std=gnu99 -ffunction-sections -fdata-sections

CXXFLAGS = -c -Os -mlongcalls -mtext-section-literals -fno-exceptions \
	-fno-rtti -falign-functions=4 -std=c++11 -MMD

LDFLAGS = -nostdlib -Wl,--gc-sections -Wl,--no-check-sections -u call_user_start -Wl,-static -Wl,-wrap,system_restart_local -Wl,-wrap,register_chipv6_phy

################################################################################################
####
#### RULES
####

.PHONY: all arduino dirs clean upload

all: show_variables dirs core libs bin size

show_variables:
	$(info [ARDUINO_LIBS] : $(ARDUINO_LIBS))
	$(info [USER_LIBS] : $(USER_LIBS))

dirs:
	@mkdir -p $(BUILD_OUT)
	@mkdir -p $(BUILD_OUT)/core
	@mkdir -p $(BUILD_OUT)/spiffs

clean:
	rm -rf $(BUILD_OUT)

core: dirs $(BUILD_OUT)/core/core.a

libs: dirs $(OBJ_FILES)

bin: $(BUILD_OUT)/$(TARGET).bin

$(BUILD_OUT)/core/%.o: $(ESP_CORES)/%.c
	$(CC) $(DEFINES) $(CORE_INC:%=-I%) $(CFLAGS) -o $@ $<

$(BUILD_OUT)/spiffs/%.o: $(ESP_CORES)/spiffs/%.c
	$(CC) $(DEFINES) $(CORE_INC:%=-I%) $(CFLAGS) -o $@ $<

$(BUILD_OUT)/core/%.o: $(ESP_CORES)/%.cpp
	$(CXX) $(DEFINES) $(CORE_INC:%=-I%) $(CXXFLAGS) -o $@ $<

$(BUILD_OUT)/core/%.S.o: $(ESP_CORES)/%.S
	$(CC) $(ASFLAGS) -o $@ $<

$(BUILD_OUT)/core/core.a: $(CORE_OBJS)
	$(AR) cru $@ $(CORE_OBJS)

$(BUILD_OUT)/core/%.c.o: %.c
	$(CC) $(DEFINES) $(CFLAGS) $(INCLUDES) -o $@ $<

$(BUILD_OUT)/core/%.cpp.o: %.cpp
	$(CXX) $(DEFINES) $(CXXFLAGS) $(INCLUDES) $< -o $@

$(BUILD_OUT)/%.c.o: %.c
	$(CC) $(DEFINES) $(CFLAGS) $(INCLUDES) -o $@ $<

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

size : $(BUILD_OUT)/$(TARGET).elf
		$(SIZE) -A $(BUILD_OUT)/$(TARGET).elf | grep -E '^(?:\.text|\.data|\.rodata|\.irom0\.text|)\s+([0-9]+).*'


$(BUILD_OUT)/$(TARGET).bin: $(BUILD_OUT)/$(TARGET).elf
	echo "Building BIN ..."
	$(ESPTOOL) -eo $(ESP_HOME)/bootloaders/eboot/eboot.elf -bo $(BUILD_OUT)/$(TARGET).bin \
		-bm $(FLASH_MODE) -bf $(FLASH_FREQ) -bz $(FLASH_SIZE) \
		-bs .text -bp 4096 -ec -eo $(BUILD_OUT)/$(TARGET).elf -bs .irom0.text -bs .text -bs .data -bs .rodata -bc -ec


upload: $(BUILD_OUT)/$(TARGET).bin size
	$(ESPTOOL) $(ESPTOOL_VERBOSE) -cd $(UPLOAD_RESETMETHOD) -cb $(UPLOAD_SPEED) -cp $(SERIAL_PORT) -ca 0x00000 -cf $(BUILD_OUT)/$(TARGET).bin

ota: $(BUILD_OUT)/$(TARGET).bin
	$(ESPOTA) 192.168.1.184 8266 $(BUILD_OUT)/$(TARGET).bin

term:
	minicom -D $(SERIAL_PORT) -b $(UPLOAD_SPEED)

print-%: ; @echo $* = $($*)

-include $(OBJ_FILES:.o=.d)

printall:
	@echo ""
	@echo "### DIRECTORIES ###"
	@echo "TARGET=$(TARGET)"
	@echo "ROOT_DIR=$(ROOT_DIR)"
	@echo "ARDUINO_HOME=$(ARDUINO_HOME)"
	@echo "ARDUINO_LIBS=$(ARDUINO_LIBS)"
	@echo "ESP_HOME=$(ESP_HOME)"
	@echo "ESP_CORES=$(ESP_CORES)"
	@echo "XTENSA_TOOLCHAIN=$(XTENSA_TOOLCHAIN)"
	@echo "ESPRESSIF_SDK=$(ESPRESSIF_SDK)"
	@echo "BUILD_OUT=$(BUILD_OUT)"
	@echo "ULIBDIRS=$(ULIBDIRS)"
	@echo "ALIBDIRS=$(ALIBDIRS)"
	@echo "USER_LIBDIR=$(USER_LIBDIR)"
	@echo "USER_LIBS=$(USER_LIBS)"
	@echo ""
	@echo "### FILES AND TOOLS ###"
	@echo "BOARDS_TXT=$(BOARDS_TXT)"
	@echo "PARSE_BOARD=$(PARSE_BOARD)"
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
	@echo ""
	@echo "### LISTS OF DIRECTORIES ###"
	@echo "CORE_INC=$(CORE_INC)"
	@echo "INCLUDES=$(INCLUDES)"
	@echo "USRCDIRS=$(USRCDIRS)"
	@echo "VPATH=$(VPATH)"
	@echo ""
	@echo "### LISTS OF FILES ###"
	@echo "CORE_SSRC=$(CORE_SSRC)"
	@echo "CORE_SRC=$(CORE_SRC)"
	@echo "CORE_CXXSRC=$(CORE_CXXSRC)"
	@echo "CORE_OBJS=$(CORE_OBJS)"
	@echo "LOCAL_SRCS=$(LOCAL_SRCS)"
	@echo "OBJ_FILES=$(OBJ_FILES)"
	@echo "LIB_CXXSRC=$(LIB_CXXSRC)"
	@echo "LIB_INOSRC=$(LIB_INOSRC)"
	@echo "LIB_SRC=$(LIB_SRC)"
	@echo "USER_CXXSRC=$(USER_CXXSRC)"
	@echo "USER_HPPSRC=$(USER_HPPSRC)"
	@echo "USER_HSRC=$(USER_HSRC)"
	@echo "USER_SRC=$(USER_SRC)"

