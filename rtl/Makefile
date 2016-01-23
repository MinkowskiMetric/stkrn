K_LIBNAME=rtl.ka
BL_LIBNAME=rtl.bla
U_LIBNAME=rtl.ua

CMN_SOURCES=memory.c printf.c
K_SOURCES=
BL_SOURCES=
U_SOURCES=

K_OBJECTS=$(CMN_SOURCES:.c=.ko) $(K_SOURCES=.c=.ko)
BL_OBJECTS=$(CMN_SOURCES:.c=.blo) $(BL_SOURCES=.c=.blo)
U_OBJECTS=$(CMN_SOURCES:.c=.uo) $(U_SOURCES=.c=.uo)

INCLUDES=-I../inc
LDFLAGS=-m32 -ffreestanding -nostdlib
CFLAGS=-g -m32 -c -ffreestanding -nostdlib $(INCLUDES) -D_IS_RTL_=1

K_CFLAGS=$(CFLAGS) -D_IS_RTL_KERNEL_=1
BL_CFLAGS=$(CFLAGS) -D_IS_RTL_BOOTLOADER_=1
U_CFLAGS=$(CFLAGS) -D_IS_RTL_USER_=1

.SUFFIXES: .ko .blo .uo

all: $(K_LIBNAME) $(BL_LIBNAME) $(U_LIBNAME)

$(K_LIBNAME): $(K_OBJECTS)
	ar cr $(K_LIBNAME) $(K_OBJECTS)

$(BL_LIBNAME): $(BL_OBJECTS)
	ar cr $(BL_LIBNAME) $(BL_OBJECTS)

$(U_LIBNAME): $(U_OBJECTS)
	ar cr $(U_LIBNAME) $(U_OBJECTS)

.c.ko:
	clang $(K_CFLAGS) $< -o $@

.c.blo:
	clang $(BL_CFLAGS) $< -o $@

.c.uo:
	clang $(U_CFLAGS) $< -o $@

clean:
	rm -f $(K_OBJECTS) $(K_LIBNAME) $(BL_OBJECTS) $(BL_LIBNAME) $(U_OBJECTS) $(U_LIBNAME)

.PHONY: clean

clean:

