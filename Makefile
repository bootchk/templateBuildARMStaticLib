# Build static library (archive) for ARM
# 
# Derived from Nordic example Makefiles.
# So this is specific to ARM Cortex M4 (see below: cortex-m4)
#
# This Makefile supports c++ but uses .c file suffix and does not support .cpp suffix
# 
# To use the product libfoo.a (to link it in):
# !!! Note libfoo must come after any object files that use it.
# ??? is -static required?
# arm-none-eabi-gcc -static main.c -L . -lfoo -o <executable_name>.out
#
# Doesn't make sense to build shared or dynamically linked library: no OS on bare metal



export OUTPUT_FILENAME
#MAKEFILE_NAME := $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
MAKEFILE_NAME := $(MAKEFILE_LIST)
MAKEFILE_DIR := $(dir $(MAKEFILE_NAME) ) 

# Doesn't require NRF SDK



MK := mkdir
RM := rm -rf


# Symbols for Gnu ARM cross toolchain
GNU_INSTALL_ROOT := /usr
GNU_PREFIX := arm-none-eabi

# Toolchain commands
#lkk was gcc
CC              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-g++'
AS              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-as'
AR              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-ar'
LD              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-ld'
NM              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-nm'
OBJDUMP         := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-objdump'
OBJCOPY         := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-objcopy'
SIZE            := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-size'

#function for removing duplicates in a list
remduplicates = $(strip $(if $1,$(firstword $1) $(call remduplicates,$(filter-out $(firstword $1),$1))))


# source files of the library
C_SOURCE_FILES +=  foo.c

# No sources from NRF SDK
# No asm files
# No  includes from NRF SDK



OBJECT_DIR = _build
BUILD_DIR = $(OBJECT_DIR)

# Sorting removes duplicates
BUILD_DIRECTORIES := $(sort $(OBJECT_DIR) $(BUILD_DIR) $(LISTING_DIRECTORY) )



# lkk no flags specific to Nordic

# lkk flags for ARM ISA in Nordic nrf52 target
CFLAGS += -mcpu=cortex-m4
CFLAGS += -mthumb -mabi=aapcs 

# lkk not valid for g++: CFLAGS += --std=gnu11   original was gnu99
# lkk excise -Werror
# lkk add -fpermissive for compiling nrf C code that is non-strict
#CFLAGS += -fpermissive 
# lkk add -std=c++11 for support of nullptr
CFLAGS += -std=c++11

CFLAGS += -Wall -O0 -g3
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
# keep every function in separate section. This will allow linker to dump unused functions
CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing
CFLAGS += -fno-builtin --short-enums 
#lkk
CFLAGS += -DDEBUG
#CFLAGS += -fshort-wchar

# no linker flags
# no assembler flags

# tell archiver to expect object files in arm-elf format?
# lkk I don't think this matters, and I don't know which to choose
# 'arm-elf' is not supported by arm-none-eabi-ar
ARFLAGS += --target elf32-littlearm
#ARFLAGS += --target elf32-little




# name used for single product, lacking suffix.
# E.g. product will be file with name foo.ar
PRODUCT_NAME = foo
# By convention, name is of form lib<foo>.a
ARCHIVE_PRODUCT_FILENAME = lib$(PRODUCT_NAME).a
# target is in build dir
ARCHIVE_TARGET = $(BUILD_DIR)/$(ARCHIVE_PRODUCT_FILENAME)


#default target - first one defined
default: clean $(ARCHIVE_TARGET) test

all: clean $(ARCHIVE_TARGET) test
	$(MAKE) -f $(MAKEFILE_NAME) -C $(MAKEFILE_DIR) -e cleanobj
	$(MAKE) -f $(MAKEFILE_NAME) -C $(MAKEFILE_DIR) -e $(ARCHIVE_TARGET)


help:
	@echo following targets are available:
	@echo 	$(PRODUCT_FILENAME)

C_SOURCE_FILE_NAMES = $(notdir $(C_SOURCE_FILES))
C_PATHS = $(call remduplicates, $(dir $(C_SOURCE_FILES) ) )
C_OBJECTS = $(addprefix $(OBJECT_DIR)/, $(C_SOURCE_FILE_NAMES:.c=.o) )


vpath %.c $(C_PATHS)

OBJECTS = $(C_OBJECTS)

# compile a test prog that calls library
# Note on link:
# - using CC to link
# - uses same CFLAGS (for ARM) that were used for the static library
# - --specs=nosys.specs means: cross linking to target with no OS, don't use _exit, etc.
test: $(ARCHIVE_TARGET) main.c
	$(CC) $(CFLAGS) -c main.c -o $(BUILD_DIR)/main.o
	$(CC) $(CFLAGS) $(BUILD_DIR)/main.o -L_build -lfoo --specs=nosys.specs -o $(BUILD_DIR)/main.out


## Create build directories
$(BUILD_DIRECTORIES):
	@echo $(MAKEFILE_NAME)
	$(MK) $@

# Create objects from C SRC files
$(OBJECT_DIR)/%.o: %.c
	@echo Compiling: $(notdir $<)
	$(CC) $(CFLAGS) $(INC_PATHS) -c -o $@ $<
	
# Archive
#lkk ARFLAGS must follow objects
# symbol for member is $%
# Note this really replaces things in the archive, but clean deleted it
# Somehow 'rv' is added to this command???
$(ARCHIVE_TARGET): $(BUILD_DIRECTORIES) $(OBJECTS)
	@echo Archiving : $@ 
	@echo Objects: $(OBJECTS)
	$(AR) $(ARFLAGS) $(ARCHIVE_TARGET) $(OBJECTS) 
	

clean:
	$(RM) $(BUILD_DIRECTORIES)

cleanobj:
	$(RM) $(BUILD_DIRECTORIES)/*.o

