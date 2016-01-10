all: boot.bin

boot.o: boot.S
	as -o boot.o boot.S

boot.out: boot.o
	ld -o boot.out boot.o -Ttext 0x0

boot.bin: boot.out
	objcopy -O binary -j .text boot.out boot.bin

boot.floppy: boot.bin
	dd bs=512 if=/dev/zero of=boot.floppy count=1440
	dd bs=512 if=boot.bin of=boot.floppy conv=nocreat,notrunc count=5 seek=0

clean:
	rm boot.o boot.bin boot.out boot.floppy

