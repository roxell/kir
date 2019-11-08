#!/bin/bash
# SPDX-License-Identifier: MIT

set -e
#set -xe

MACHINE=${1}
cd /lava-lxc

find . -type f -name 'modules-*'
echo "PRINTOUT"
local_modules=$(find . -type f -name 'modules-*')
echo "PRINTOUT MODULES: ${local_modules}"
file ${local_modules}
local_kernel=$(find . -type f -name '*Image*.bin')
echo "PRINTOUT KERNEL: ${local_kernel}"
file ${local_kernel}
local_rootfs_ext4=$(find . -type f -name '*rpb-console-image-lkft-*.ext4*')
echo "PRINTOUT ROOTFS: ${local_rootfs_ext4}"
file ${local_rootfs_ext4}

case ${MACHINE} in
	am57xx-evm)
		local_dtb=$(find . -type f -name '*Image*.dtb')
		echo "PRINTOUT DTB: ${local_dtb}"
		file ${local_dtb}
		./kir/repack_boot.sh -t "${MACHINE}" -f "${local_rootfs_ext4}" -d "${local_dtb}" -k "${local_kernel}" -m "${local_modules}"
		;;
	dragonboard-410c)

		local_dtb=$(find . -type f -name '*Image*.dtb')
		echo "PRINTOUT DTB: ${local_dtb}"
		file ${local_dtb}
		./kir/repack_boot.sh -t "${MACHINE}" -d "${local_dtb}" -k "${local_kernel}"
		./kir/resize_rootfs.sh -s -f "${local_rootfs_ext4}" -o "${local_modules}"
		;;
	hikey)
		local_ptable=$(find . -type f -name '*ptable*-8g.img')
		echo "PRINTOUT ptable: ${local_ptable}"
		file ${local_ptable}
		local_boot=$(find . -type f -name 'boot*.uefi.img')
		mv ${local_boot} boot.img
		local_boot=boot.img
		echo "PRINTOUT boot: ${local_boot}"
		file ${local_boot}
		local_dtb=$(find . -type f -name '*Image*.dtb')
		echo "PRINTOUT DTB: ${local_dtb}"
		file ${local_dtb}
		./kir/repack_boot.sh -t "${MACHINE}" -f "${local_rootfs_ext4}" -d "${local_dtb}" -k "${local_kernel}" -m "${local_modules}"
		;;
	*)
		usage
		exit 1
		;;
esac

ls
pwd
case ${MACHINE} in
	am57xx-evm|dragonboard-410c|hikey)
		local_rootfs_img=$(find . -type f -name '*rpb-console-image-lkft-*.img')
		mv ${local_rootfs_img} rpb-console-image-lkft.rootfs.img
		ls -l
		pwd
		file rpb-console-image-lkft.rootfs.img
		;;
esac