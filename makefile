#makefile
# arm-linux-gnueabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -c boot.S -o boot.o
# arm-linux-gnueabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -std=gnu99 -c kernel.c -o kernel.o -O2 -Wall -Wextra
# arm-linux-gnueabi-gcc -T linker.ld -o myos.elf -ffreestanding -O2 -nostdlib boot.o kernel.o
# arm-linux-gnueabi-objcopy myos.elf -O binary myos.bin
#
# Created on:
#     Author: Ivan Di Prima
#
CXXFLAGS = -mcpu=arm1176jzf-s -fpic -ffreestanding -std=gnu99 -O2 -Wall -Wextra
ASMFLAGS = -mcpu=arm1176jzf-s -fpic -ffreestanding

CPP = arm-linux-gnueabi-gcc
LD= arm-linux-gnueabihf-ld
OBJCOPY = arm-linux-gnueabi-objcopy

BOOTOBJ=boot.o
BOOTSRC = boot.S
KERNELSRC = kernel.c
KERNELOBJ = kernel.o
KERNELELF = kernel.elf
TARGET= kernel.bin
MAP=kernel.map

$(TARGET) : $(KERNELOBJ) $(BOOTOBJ)
	$(LD) -T linker.ld -Map $(MAP) -o $(KERNELELF) -O2 -nostdlib $(BOOTOBJ) $(KERNELOBJ)
	$(OBJCOPY) $(KERNELELF) -O binary $(TARGET)

$(KERNELOBJ) : $(KERNELSRC)
	$(CPP) $(CXXFLAGS) -c $(KERNELSRC) -o $(KERNELOBJ)

$(BOOTOBJ) : $(BOOTSRC)
	$(CPP) $(ASMFLAGS) -c $(BOOTSRC) -o $(BOOTOBJ)

all:	$(TARGET)
	echo "qemu-system-arm -m 256 -M raspi2 -serial stdio -kernel kernel.elf"

clean:
	rm -f $(BOOTOBJ) $(KERNELOBJ) $(TARGET) $(KERNELELF)
