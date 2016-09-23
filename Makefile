# Build archive for ARM

# lkk notes
# 
# Derived from Nordic example Makefiles
#
# This Makefile supports c++ but uses .c file suffix and does not support .cpp suffix




export OUTPUT_FILENAME
#MAKEFILE_NAME := $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
MAKEFILE_NAME := $(MAKEFILE_LIST)
MAKEFILE_DIR := $(dir $(MAKEFILE_NAME) ) 

# lkk hack
#HOME = /home/bootch

# Doesn't require NRF SDK

TEMPLATE_PATH = $(NRF_SDK_ROOT)/components/toolchain/gcc



MK := mkdir
RM := rm -rf

VERBOSE = 1

#echo suspend
ifeq ("$(VERBOSE)","1")
NO_ECHO := 
else
NO_ECHO := @
endif

# Symbols for Gnu ARM cross toolchain
GNU_INSTALL_ROOT := /usr
GNU_PREFIX := arm-none-eabi

# Toolchain commands
#lkk was gcc
CC              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-g++'
AS              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-as'
#lkk AR              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-ar' -r
AR              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-ar' -rv
LD              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-ld'
NM              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-nm'
OBJDUMP         := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-objdump'
OBJCOPY         := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-objcopy'
SIZE            := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-size'

#function for removing duplicates in a list
remduplicates = $(strip $(if $1,$(firstword $1) $(call remduplicates,$(filter-out $(firstword $1),$1))))

# No sources from NRF SDK

C_SOURCE_FILES +=  foo.c

# No asm files


# No  includes from NRF SDK



OBJECT_DIRECTORY = _build
LISTING_DIRECTORY = $(OBJECT_DIRECTORY)
OUTPUT_BINARY_DIRECTORY = $(OBJECT_DIRECTORY)

# Sorting removes duplicates
BUILD_DIRECTORIES := $(sort $(OBJECT_DIRECTORY) $(OUTPUT_BINARY_DIRECTORY) $(LISTING_DIRECTORY) )

#flags common to all targets

# lkk no flags specific to Nordic

# lkk flags for ARM ISA in Nordic nrf52 target
CFLAGS += -mcpu=cortex-m4
CFLAGS += -mthumb -mabi=aapcs 

# lkk flags general to all targets
# lkk not valid for g++: CFLAGS += --std=gnu11   original was gnu99
# lkk excise -Werror
# lkk add -fpermissive for compiling nrf C code that is non-strict
# lkk add -std=c++11 for support of nullptr
CFLAGS += -fpermissive -std=c++11

CFLAGS += -Wall -O0 -g3
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
# keep every function in separate section. This will allow linker to dump unused functions
CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing
CFLAGS += -fno-builtin --short-enums 
#lkk
CFLAGS += -DDEBUG
#CFLAGS += -fshort-wchar

#TODO no linker flags
# keep every function in separate section. This will allow linker to dump unused functions
LDFLAGS += -Xlinker -Map=$(LISTING_DIRECTORY)/$(OUTPUT_FILENAME).map
LDFLAGS += -mthumb -mabi=aapcs 
#LDFLAGS += -L $(TEMPLATE_PATH) 
#LDFLAGS += -T$(LINKER_SCRIPT)
LDFLAGS += -mcpu=cortex-m4
LDFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
# let linker to dump unused sections
LDFLAGS += -Wl,--gc-sections
# use newlib in nano version
# LDFLAGS += --specs=nano.specs 
LDFLAGS += -lc -lnosys

# lkk no assembler flags specific to target

# tell archiver to expect object files in arm-elf format
# Not arm-elf
#ARFLAGS += --target elf32-littlearm
#ARFLAGS += --target arm-elf
ARFLAGS += --target elf32-little







# name used for single product, lacking suffix.
# E.g. product will be file with name foo.ar
PRODUCT_NAME = foo
ARCHIVE_PRODUCT_FILENAME = $(PRODUCT_NAME).ar
LIBRARY_PRODUCT_FILENAME = $(PRODUCT_NAME).a

#default target - first one defined
default: clean $(OUTPUT_BINARY_DIRECTORY)/$(LIBRARY_PRODUCT_FILENAME)

all: clean
	$(NO_ECHO)$(MAKE) -f $(MAKEFILE_NAME) -C $(MAKEFILE_DIR) -e cleanobj
	$(NO_ECHO)$(MAKE) -f $(MAKEFILE_NAME) -C $(MAKEFILE_DIR) -e $(OUTPUT_BINARY_DIRECTORY)/$(PRODUCT_FILENAME)


help:
	@echo following targets are available:
	@echo 	$(PRODUCT_FILENAME)

C_SOURCE_FILE_NAMES = $(notdir $(C_SOURCE_FILES))
C_PATHS = $(call remduplicates, $(dir $(C_SOURCE_FILES) ) )
C_OBJECTS = $(addprefix $(OBJECT_DIRECTORY)/, $(C_SOURCE_FILE_NAMES:.c=.o) )


vpath %.c $(C_PATHS)

OBJECTS = $(C_OBJECTS)

#lkk no linker script
#test: LINKER_SCRIPT=gcc_nrf52.ld


## Create build directories
$(BUILD_DIRECTORIES):
	echo $(MAKEFILE_NAME)
	$(MK) $@

# Create objects from C SRC files
$(OBJECT_DIRECTORY)/%.o: %.c
	@echo Compiling file: $(notdir $<)
	$(NO_ECHO)$(CC) $(CFLAGS) $(INC_PATHS) -c -o $@ $<
	
# Archive
#lkk ARFLAGS must follow objects
$(OUTPUT_BINARY_DIRECTORY)/$(PRODUCT_FILENAME): $(BUILD_DIRECTORIES) $(OBJECTS)
	@echo Archiving : $(OUTPUT_FILENAME).ar
	$(NO_ECHO)$(AR) $(OBJECTS) $(ARFLAGS) -o $(OUTPUT_BINARY_DIRECTORY)/$(PRODUCT_FILENAME)
	
# Link
#lkk CC calls LD
$(OUTPUT_BINARY_DIRECTORY)/$(LIBRARY_PRODUCT_FILENAME): $(BUILD_DIRECTORIES) $(OBJECTS)
	@echo Linking target: 
	$(NO_ECHO)$(CC) $(LDFLAGS) $(OBJECTS) $(LIBS) -lm -o $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).a




clean:
	$(RM) $(BUILD_DIRECTORIES)

cleanobj:
	$(RM) $(BUILD_DIRECTORIES)/*.o

