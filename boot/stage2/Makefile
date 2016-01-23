SOURCES=
CPPSOURCES=main.cpp
ASMSOURCES=startup.S
OBJECTS=$(SOURCES:.c=.o) $(CPPSOURCES:.cpp=.o) $(ASMSOURCES:.S=.o)
EXECUTABLE=stage2
INCLUDES=-I../../inc
LIBPATHS=
LIBS=../../rtl/rtl.bla
LDFLAGS=-g -m32 -ffreestanding -nostdlib $(LIBPATHS) -Xlinker -T stage2.link
CFLAGS=-g -m32 -c -std=c++11 -ffreestanding -nostdlib $(INCLUDES)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS) $(LIBS)
	clang++ $(LDFLAGS) $(OBJECTS) $(LIBS) -o $@

.c.o .cpp.o:
	clang++ $(CFLAGS) $< -o $@
	
.S.o:
	as -march=i386 --32 $< -o $@

clean:
	rm -f $(OBJECTS) $(EXECUTABLE)

