#!/bin/sh

set -e

if [ "$randomizeDisk" != "false" ]
then
  echo "Randomizing disk"
  cryptsetup open --type plain /dev/sda container --key-file /dev/random
  set +e
  ## this command will file writing the last block, when the disk is full
  dd if=/dev/zero of=/dev/mapper/container bs=1M status=progress
  set -e
  cryptsetup close /dev/mapper/container
fi

echo "Partitioning disk..."
cat <<FDISK | fdisk /dev/sda
n
p


+200M
a
t
be
n
p



t
2
82
w
FDISK

fdisk -l

echo "Making boot filesystem"
mkfs.ext4 -m 0 -j -L nixos-boot /dev/sda1


echo -n "Root block device password is: $diskPassphrase"
echo

echo "Setting up crypt on root filesystem"
echo -n "$diskPassphrase" | cryptsetup -v luksFormat /dev/sda2 -

echo "Openning crypt volume"
echo -n "$diskPassphrase" | cryptsetup -v open /dev/sda2 cryptroot

echo "Creating zfs pool"
zpool create -f -o ashift=12 -o altroot=/mnt tank cryptroot
zfs set atime=off tank
zfs set compression=lz4 tank

zpool status

echo "Creating zfs filesystems"
zfs create -o mountpoint=none tank/root
zfs create -o mountpoint=legacy tank/root/nixos
zfs create -o mountpoint=legacy tank/home

zfs set com.sun:auto-snapshot=true tank/home

echo "Mounting filesystems"
mount -t zfs tank/root/nixos /mnt

mkdir /mnt/home
mount -t zfs tank/home /mnt/home

mkdir /mnt/boot
mount /dev/disk/by-id/*HARDDISK*part1 /mnt/boot

echo "Generating configuration files"
nixos-generate-config --root /mnt

mv /tmp/custom.nix /mnt/etc/nixos/custom.nix

#generate a random host-id with the right format (8 hex chars)
hostId=$(head -c4 /dev/urandom | od -A none -t x4 |  tr -d '[[:space:]]')
sed -i "s|HOSTNAME|$hostName|g" /mnt/etc/nixos/custom.nix
sed -i "s|HOSTID|$hostId|g" /mnt/etc/nixos/custom.nix
sed -i "s|USER|$userName|g" /mnt/etc/nixos/custom.nix
# fixme escape password
sed -i "s|PASSWORD|$userPassword|g" /mnt/etc/nixos/custom.nix
sed -i "s|SSHKEY|$userAuthorizedKey|g" /mnt/etc/nixos/custom.nix
sed -i "s|KEYMAP|$consoleKeyMap|g" /mnt/etc/nixos/custom.nix
sed -i "s|.*hardware-configuration.nix.*|./hardware-configuration.nix ./custom.nix|" /mnt/etc/nixos/configuration.nix

cat /mnt/etc/nixos/*

echo "Installing NixOs"
nixos-install

echo "Cleaning up installation"
cat /tmp/postinstall.sh | nixos-install --chroot
