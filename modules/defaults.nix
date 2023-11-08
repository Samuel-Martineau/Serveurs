{ pkgs, name, lib, ... }:
let params = lib.importJSON ../params.json;
in {
  nixpkgs.system = "x86_64-linux";
  system.stateVersion = "23.05";

  networking.hostName = name;

  deployment.keys."tailscale-authkey.txt".keyFile =
    ../keys/tailscale-authkey.txt;

  environment.systemPackages = with pkgs; [ vim wget curl httpie htop ];

  time.timeZone = params.timezone;

  nix.optimise.automatic = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting ""
    '';
  };

  system.autoUpgrade.enable = true;

  virtualisation.docker.enable = true;

  users = {
    mutableUsers = false;
    users.root = {
      shell = pkgs.fish;
      hashedPassword = params.hashedPassword;
    };
  };

  imports = [
    (../hardware-configurations + "/${name}.nix")
    ./networking.nix
    ./containers.nix
  ];
}
