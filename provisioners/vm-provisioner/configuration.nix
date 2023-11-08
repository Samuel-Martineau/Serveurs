{ lib, ... }:
let
  params = lib.importJSON ../../params.json;
  vm = lib.importJSON ./vm.json;
in {
  system.stateVersion = "23.05";

  networking.hostName = vm.name;

  services.tailscale.enable = true;

  proxmox.qemuConf = {
    cores = vm.cores;
    memory = vm.memory;
    name = vm.name;
    diskSize = toString vm.storage;
  };

  users.users.root = { hashedPassword = params.hashedPassword; };
}
