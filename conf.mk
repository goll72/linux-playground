ARCH := $(shell arch)

LINUX := linux

ROOTFS := rootfs
OVERLAY := overlay
ROOTFSIMG := rootfs.img

# Provides `poweroff`
EXTRA_PKG_LIST := klibc-utils

KERNEL_RELEVANT_DIRS := fs
KERNEL_SRC_EDITED := $(shell git -C $(LINUX) status --porcelain=v1 $(KERNEL_RELEVANT_DIRS) | awk '/^(A|M)/ { print "$(LINUX)/" $$2; }')

ifeq ($(ARCH),i386)
	LINUX_ARCH := x86
	DEBIAN_ARCH := i386
	CONSOLE := ttyS0
	KERNEL_IMAGE := vmlinux
else ifeq ($(ARCH),x86_64)
	LINUX_ARCH := x86
	DEBIAN_ARCH := amd64
	CONSOLE := ttyS0
	KERNEL_IMAGE := vmlinux
else ifeq ($(ARCH),aarch64)
	LINUX_ARCH := arm64
	DEBIAN_ARCH := arm64
	CONSOLE := ttyAMA0
	KERNEL_IMAGE := arch/arm64/boot/Image
else
	error "Add proper arch attributes for $(ARCH) in conf.mk"
endif

KERNEL_CMDLINE := root=/dev/vda rw console=$(CONSOLE)

-include conf.local.mk
