SOURCES=main.c
ASMSOURCES=startup.S
OBJECTS=$(SOURCES:.c=.o) $(ASMSOURCES:.S=.o)
EXECUTABLE=stage2
LDFLAGS=
CFLAGS=

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	ld $(OBJECTS) -T stage2.link -o $@

.c.o:
	clang-3.7 $(CFLAGS) $< -o $@

.S.o:
	as $< -o $@

clean:
	rm -f $(OBJECTS) $(EXECUTABLE)

