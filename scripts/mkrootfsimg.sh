#!/bin/sh

set -e
umask 011

ROOTFSIMG=$1

shift

# How much to allocate for rootfs.img, in MiB
TOTAL=100

for arg in "$@"; do
    TOTAL=$(( TOTAL + $(du -sm "$arg" | cut -f 1) ))
done

fallocate -l ${TOTAL}M rootfs.img
mkfs.btrfs -f rootfs.img

TMP=$(mktemp -d)

mount rootfs.img "$TMP"
rsync -avP "$@" "$TMP"/
umount "$TMP"

umount $TMP

rmdir "$TMP"
