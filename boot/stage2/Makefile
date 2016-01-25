SOURCES=memory.c
CPPSOURCES=main.cpp
ASMSOURCES=startup.S
OBJECTS=$(SOURCES:.c=.o) $(CPPSOURCES:.cpp=.o) $(ASMSOURCES:.S=.o)
EXECUTABLE=stage2
INCLUDES=-I../../inc
LIBPATHS=
LIBS=../../rtl/rtl.bla
LDFLAGS=-g -m32 -ffreestanding -nostdlib $(LIBPATHS) -Xlinker -T stage2.link
CPPFLAGS=-g -m32 -c -std=c++11 -ffreestanding -nostdlib $(INCLUDES)
CFLAGS=-g -m32 -c -ffreestanding -nostdlib $(INCLUDES)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS) $(LIBS)
	clang $(LDFLAGS) $(OBJECTS) $(LIBS) -lgcc -o $@

.c.o:
	clang $(CFLAGS) $< -o $@
	
.cpp.o:
	clang++ $(CPPFLAGS) $< -o $@
	
.S.o:
	as -march=i386 --32 $< -o $@

clean:
	rm -f $(OBJECTS) $(EXECUTABLE)

