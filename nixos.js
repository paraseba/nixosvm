{
  "description": "NixOs vagrant box creation. ZFS + LUKS",

  "variables": {
    "nixosIsoUrl": "https://nixos.org/releases/nixos/latest-iso-minimal-x86_64-linux",
    "nixosIsoSha256": "893e4596469cf872bebb880134622ddcdfcff3040761f2aad259f6aa3b4ba87e",

    "memoryMB": "4096",
    "cpus": "2",
    "consoleKeyMap": "us",

    "diskPassphrase": null,
    "diskSizeMB": "3000",

    "virtualMachineName": "nixos",
    "hostName": "nixosvm",

    "userName": "vagrant",
    "userPassword": null,
    "userAuthorizedKey": null,

    "randomizeDisk": "true"
  },

  "builders": [
    {
      "type": "virtualbox-iso",

      "vboxmanage": [
        ["modifyvm", "{{.Name}}", "--memory", "{{user `memoryMB`}}"],
        ["modifyvm", "{{.Name}}", "--cpus", "{{user `cpus`}}"]
      ],

      "vboxmanage_post": [
        ["storageattach", "{{.Name}}",
        "--storagectl", "IDE Controller",
        "--device", "0", "--port", "0", "--medium", "none"]
      ],

      "iso_url": "{{user `nixosIsoUrl`}}",
      "iso_checksum": "{{user `nixosIsoSha256`}}",
      "iso_checksum_type": "sha256",

      "ssh_username": "root",
      "ssh_key_path": "./scripts/install_rsa",

      "shutdown_command": "echo 'packer' | shutdown -P now",
      "guest_additions_mode": "disable",

      "disk_size": "{{user `diskSizeMB`}}",
      "vm_name": "{{user `virtualMachineName`}}",
      "guest_os_type": "Linux_64",
      "http_directory": "scripts",

      "boot_wait": "5s",
      "boot_command": [
        "<enter><wait10><wait10>",

        "mkdir -m 0700 .ssh<enter>",
        "curl http://{{ .HTTPIP }}:{{ .HTTPPort}}/install_rsa.pub > .ssh/authorized_keys<enter>",

        "<wait>",
        "start sshd<enter>"
      ]
    }
  ],

  "provisioners": [

    { "type": "file",
      "source": "scripts/custom.nix",
      "destination": "/tmp/custom.nix"
    },

    { "type": "file",
      "source": "scripts/postinstall.sh",
      "destination": "/tmp/postinstall.sh"
    },

    { "type": "shell",
      "script": "./scripts/install.sh",
      "environment_vars": [
         "diskPassphrase={{user `diskPassphrase`}}",
         "hostName={{user `hostName`}}",
         "consoleKeyMap={{user `consoleKeyMap`}}",
         "randomizeDisk={{user `randomizeDisk`}}",
         "userName={{user `userName`}}",
         "userPassword={{user `userPassword`}}",
         "userAuthorizedKey={{user `userAuthorizedKey`}}"
      ]
    }
  ]
}
