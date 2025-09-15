ASM     = nasm
CC      = gcc
CC16    = /usr/bin/watcom/binl/wcc
LD16    = /usr/bin/watcom/binl/wlink

SRC_DIR   = src
TOOLS_DIR = tools
BUILD_DIR = build

.PHONY: all floppy_image kernel bootloader clean tools_fat

all: floppy_image tools_fat

#
# Floppy image
#
floppy_image: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: bootloader kernel | $(BUILD_DIR)
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img bs=512 count=2880
	mkfs.fat -F 12 -n "CHAOS" $(BUILD_DIR)/main_floppy.img
	dd if=$(BUILD_DIR)/stage1.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/stage2.bin "::stage2.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin "::kernel.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img test.txt "::test.txt"
	mmd   -i $(BUILD_DIR)/main_floppy.img "::mydir"
	mcopy -i $(BUILD_DIR)/main_floppy.img test.txt "::mydir/test.txt"

#
# Bootloader
#
bootloader: stage1 stage2

stage1: $(BUILD_DIR)/stage1.bin
$(BUILD_DIR)/stage1.bin: | $(BUILD_DIR)
	$(MAKE) -C $(SRC_DIR)/bootloader/stage1 BUILD_DIR=$(abspath $(BUILD_DIR))

stage2: $(BUILD_DIR)/stage2.bin
$(BUILD_DIR)/stage2.bin: | $(BUILD_DIR)
	$(MAKE) -C $(SRC_DIR)/bootloader/stage2 BUILD_DIR=$(abspath $(BUILD_DIR))

#
# Kernel
#
kernel: $(BUILD_DIR)/kernel.bin
$(BUILD_DIR)/kernel.bin: | $(BUILD_DIR)
	$(MAKE) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR))

#
# Tools
#
tools_fat: $(BUILD_DIR)/tools/fat.out

$(BUILD_DIR)/tools/fat.out: $(TOOLS_DIR)/fat/*.c | $(BUILD_DIR)/tools
	$(MAKE) -C $(TOOLS_DIR)/fat BUILD_DIR=$(abspath $(BUILD_DIR))

#
# Directory creation rules
#
$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/tools:
	mkdir -p $@

#
# Clean
#
clean:
	$(MAKE) -C $(SRC_DIR)/bootloader/stage1 BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	$(MAKE) -C $(SRC_DIR)/bootloader/stage2 BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	$(MAKE) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	rm -rf $(BUILD_DIR)/*