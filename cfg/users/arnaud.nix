{ config, lib, pkgs, ... }:

let
  uid = 1000;

  description = "LightDiscord";

  hashedPassword = "$6$LRS6oz74Lt0$wxRJrD9dVK61ofjP9Cwc1ymNz6l8oknWUHx71pYqtkEY1KfeDdSU3bnslGO8A7TeM1AXYh8.p57IQ8wbVQvBO0";

  extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "git"
  ];

  shell = pkgs.fish;

  packages = with pkgs; [
      neovim
      htop
      tmux
      git
  ];

  keys = with import ../../misc/keys.nix; [
      ssh.arnaud
  ];
in {
  users.extraUsers.arnaud = {
    isNormalUser = true;
    createHome = true;

    openssh.authorizedKeys.keys = keys;

    inherit description hashedPassword shell packages uid extraGroups;
  };

  programs.fish = {
    enable = shell == pkgs.fish;
  };
}