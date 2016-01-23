BOOTIMG = bootimg
SUBDIRS = rtl boot

STAGE1 = ./boot/stage1/boot.bin
STAGE2 = ./boot/stage2/stage2
OTHERFILES = 

.PHONY: subdirs clean $(SUBDIRS)
	
all: $(BOOTIMG)

subdirs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@
	
$(BOOTIMG): $(SUBDIRS) $(STAGE1) $(STAGE2) $(OTHERFILES)
	./boot/imggen/imggen ./$(BOOTIMG) $(STAGE1) $(STAGE2) $(OTHERFILES)

clean:
	cd rtl && make clean
	cd boot && make clean
	rm -f $(BOOTIMG)
