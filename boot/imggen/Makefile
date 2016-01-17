SOURCES=imggen.cpp
TARGET=imggen

CPPFLAGS=-std=c++11

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SOURCES)
	clang++ $(CPPFLAGS) $(SOURCES) -o $(TARGET)
	
clean:
	rm -f $(TARGET)
	
