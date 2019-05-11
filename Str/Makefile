
SHELL = /bin/sh
MKDIR = mkdir -p

vpath %.asm src
vpath %.inc include

AS = nasm
LD = ld
CC = gcc-9.1.0

TARGET = str

all: $(TARGET)

$(TARGET): main.o
	$(LD) -o $@ $^

main.o: main.asm
	$(AS) -o $@ -f elf64 $^

.PHONY: clean
clean:
	$(RM) $(wildcard *.o) $(TARGET)
