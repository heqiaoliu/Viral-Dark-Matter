ARCH=$(shell muparch)

ifeq ($(ARCH),win64)
ARCH=x64
endif

ifneq ($(filter $(ARCH),win32 x64),)
MMG	 = mmg.exe
else
ifneq ($(ARCH), maci64)
MMG	 = mmg
else
MMG      = mmg -oc '-arch x86_64' -ol '-arch x86_64'
endif
endif

all:  module install

install:
	mkdir -p ../../modules/$(ARCH)
	cp $(ARCH)/modulefact.mdm ../../modules/$(ARCH)/modulefact.mdm

module:  $(ARCH)/modulefact.mdm

$(ARCH):
	mkdir -p $(ARCH)

$(ARCH)/modulefact.mdm:  $(ARCH)
	( $(MMG) -batch -novcrun -op $(ARCH) -I. modulefact.cpp )

# the module depends on its cpp source file
$(ARCH)/modulefact.mdm: modulefact.cpp

archclean:
	rm -rf $(ARCH)

clean:
	rm -rf glnx86 glnxa64 maci maci64 win32 x64
