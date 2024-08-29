linux-playground
================

This repository houses some patches to the Linux kernel that
I've made just for fun (i.e. shouldn't ever and wouldn't ever be merged), alongside
a build system to recompile the kernel as needed and aid with experimentation.

## Included patches

 - `pipefs.patch`: Allows `pipefs` (the filesystem used internally by
 the kernel for implementing pipes [and also some locking mechanism for 
 processes(?)]) to be mounted in userspace.
 - More to come?

## Build targets

 - `all`: build the rootfs image and the kernel image
 - `apply`: applies the patches specified in `P`, e.g. `make apply P=patches/pipefs.patch`
 will apply `pipefs.patch` to the `linux` local source tree.
 - `run`:  runs `qemu` and `tio` (for the serial console interface)
 - `debug`: runs `gdb`
 - `clean`: remove build artifacts and temporary files
 - `sane`: restore the terminal to a sane state (why not?)
