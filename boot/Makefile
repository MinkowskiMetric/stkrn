BOOTIMG = bootimg

SUBDIRS = stage1 stage2 imggen

STAGE1 = ./stage1/boot.bin
STAGE2 = ./stage2/stage2
OTHERFILES = 

.PHONY: subdirs clean $(SUBDIRS)
	
all: $(BOOTIMG)

subdirs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@
	
$(STAGE1): stage1

$(STAGE2): stage2

$(BOOTIMG): $(SUBDIRS) $(STAGE1) $(STAGE2) $(OTHERFILES)
	./imggen/imggen ./$(BOOTIMG) $(STAGE1) $(STAGE2) $(OTHERFILES)

clean:
	cd stage1 && make clean
	cd stage2 && make clean
	cd imggen && make clean
	rm -f $(BOOTIMG)
