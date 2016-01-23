SOURCES=
CPPSOURCES=main.cpp
ASMSOURCES=startup.S
OBJECTS=$(SOURCES:.c=.o) $(CPPSOURCES:.cpp=.o) $(ASMSOURCES:.S=.o)
EXECUTABLE=stage2
LDFLAGS=-m32
CFLAGS=-g -m32 -c -std=c++11 -ffreestanding
CPPFLAGS=$(CFLAGS)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	ld $(OBJECTS) -T stage2.link -o $@

.c.o:
	clang $(CFLAGS) $< -o $@

.cpp.o:
	clang++ $(CPPFLAGS) $< -o $@
	
.S.o:
	as -march=i386 --32 $< -o $@

clean:
	rm -f $(OBJECTS) $(EXECUTABLE)

