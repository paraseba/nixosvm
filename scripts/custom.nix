# This file is overwritten by the vagrant-nixos plugin
{ config, pkgs, ... }:
{
  boot.initrd.luks.devices = [ { name = "cryptroot"; device = "/dev/sda2"; } ];

  boot.supportedFilesystems = [ "zfs" ];

  #hardware.enableAllFirmware = true;

  fileSystems."/tmp" =
    { device = "tmpfs";
      fsType = "tmpfs";
      options = ["nosuid" "nodev" "relatime" "size=30%"];
    };


  # Define on which hard drive you want to install Grub.
  boot.loader.grub = {
    device = "/dev/sda";
    timeout = 2;
  };

  networking = {
    hostName = "HOSTNAME"; # Define your hostname.
    hostId = "HOSTID";
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "KEYMAP";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "America/Los_Angeles";
  #time.timeZone = "America/Sao_Paulo";
  #time.timeZone = "America/Buenos_Aires";

  nix.trustedBinaryCaches = [ http://hydra.cryp.to http://hydra.nixos.org ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  services = {
    zfs.autoSnapshot.enable = true;
    openssh.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.USER = {
    password = "PASSWORD";
    isNormalUser = true;
    uid = 1000;
    extraGroups = ["wheel" "systemd-journal" "lp" "atd" "video"];
    openssh.authorizedKeys.keys = [ "SSHKEY" ];
  };
}
