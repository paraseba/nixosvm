# Provision a NixOS VirtualBox VM

Create a Nixos virtual machine usable with VirtualBox by downloading Nixos ISO
and setting up.

It uses LUKS and ZFS for the filesystem.

## Usage

Make sure there are no VMs or Drives in virtual box named nixos (or whatever)
name you give the VM. Use File -> Virtual Media Manager to verify.

```bash
  packer build \
    -var 'cpus=4' \
    -var 'nixosIsoSha256=490e9ae01aa89add7aa55a7bdbf4560adf35c3f7fa28bdc070543665fbbcb1ea' \
    -var 'consoleKeyMap=dvp' \
    -var 'diskPassphrase=****' \
    -var 'diskSizeMB=1500' \
    -var 'userPassword=****' \
    -var "userAuthorizedKey=`cat ~/.ssh/id_rsa.pub`" \
    -var 'randomizeDisk=false' \
  nixos.js

```

That will create a detached virtual machine and it's drive. Then we will import it
in VirtualBox and attach the disk.

```bash
  mkdir ~/VirtualBox\ VMs/nixos && mv output-virtualbox-iso/* ~/VirtualBox\ VMs/nixos

  VBoxManage import ~/VirtualBox\ VMs/nixos/nixos.ovf

  VBoxManage storageattach nixos               \
    --storagectl 'IDE Controller'              \
    --device 0                                 \
    --port 0                                   \
    --medium ~/VirtualBox\ VMs/nixos/nixos.vdi \
    --type hdd
```

Start the VM.
