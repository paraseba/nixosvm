## Add custom configuration in this file

{ config, pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    # ...
  ];
}
