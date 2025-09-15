BUILD_DIR ?= build
CC        ?= gcc
CFLAGS    ?= -ggdb

SOURCES_C := $(wildcard *.c)
OBJECTS_C := $(patsubst %.c,$(BUILD_DIR)/tools/fat/%.o,$(SOURCES_C))

.PHONY: all fat clean

all: fat

fat: $(BUILD_DIR)/tools/fat.out

$(BUILD_DIR)/tools/fat.out: $(OBJECTS_C) | $(BUILD_DIR)/tools/fat
	$(CC) $(CFLAGS) -o $@ $(OBJECTS_C)

$(BUILD_DIR)/tools/fat/%.o: %.c | $(BUILD_DIR)/tools/fat
	$(CC) $(CFLAGS) -c -o $@ $<

# Directory creation rule (safe, no "File exists" errors)
$(BUILD_DIR)/tools/fat:
	mkdir -p $@

clean:
	rm -f $(BUILD_DIR)/tools/fat.out
	rm -rf $(BUILD_DIR)/tools/fat
