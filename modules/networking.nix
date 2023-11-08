{ config, lib, ... }:
let params = lib.importJSON ../params.json;
in {
  services.tailscale = {
    enable = true;
    authKeyFile = "/run/keys/tailscale-authkey.txt";
    ssh = true;
  };

  networking = {
    nameservers = [ "100.100.100.100" "1.1.1.1" ];
    search = [ "${params.tailnetName}.ts.net" ];

    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };

  disabledModules = [ "services/networking/tailscale.nix" ];
  imports = [ ../patches/tailscale.nix ];
}
