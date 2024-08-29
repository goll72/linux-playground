include conf.mk

all: $(ROOTFSIMG) $(LINUX)/$(KERNEL_IMAGE)

ifneq ($(P),)
apply:
	git -C $(LINUX) restore .
	git -C $(LINUX) apply --ignore-whitespace $(shell realpath --relative-to=$(LINUX) $(P))
endif

run: $(ROOTFSIMG) $(LINUX)/$(KERNEL_IMAGE)
	! [ -f qemu.pid ] || kill $$(cat qemu.pid)
	qemu-system-$(ARCH) $(QEMU_OPTS) -S -s -pidfile qemu.pid -kernel $(LINUX)/$(KERNEL_IMAGE) -append '$(KERNEL_CMDLINE)'    \
	    -display none -serial pty                                                                                            \
	    -blockdev node-name=node-storage,driver=raw,file.driver=file,file.node-name=file,file.filename=$(ROOTFSIMG)          \
	    -device virtio-blk,drive=node-storage,id=virtio0                                                                     \
	| awk '/char device redirected to \/dev\/pts\/[0-9]+ \(label .*\)/ { print $$5 > "qemu.serial"; close("qemu.serial"); } /.*/ { print > "/dev/stderr"; }' &
	sleep 0.5
	tio $$(cat qemu.serial)
	-kill $$(cat qemu.pid) && rm qemu.pid

debug:
	gdb -ex 'target remote localhost:1234' $(LINUX)/vmlinux

clean:
	rm -rf $(ROOTFS) $(ROOTFSIMG) qemu.pid qemu.serial

sane:
	tput reset
	stty sane

$(ROOTFSIMG): $(ROOTFS)/ $(OVERLAY)/
	$(SUDO) ./scripts/mkrootfsimg.sh $(ROOTFSIMG) $(ROOTFS)/ $(OVERLAY)/

$(ROOTFS)/: $(ROOTFS)/usr/bin/dpkg

$(ROOTFS)/usr/bin/dpkg:
	$(SUDO) debootstrap --arch=$(DEBIAN_ARCH) --include=$(EXTRA_PKG_LIST) --variant=minbase sid $(ROOTFS)

$(LINUX)/$(KERNEL_IMAGE): $(KERNEL_SRC_EDITED)
	cp $(LINUX)/.config.$(LINUX_ARCH) $(LINUX)/.config
	$(MAKE) -C $(LINUX) ARCH=$(LINUX_ARCH) LLVM=1 $(KERNEL_IMAGE)
