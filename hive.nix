{
  meta = { nixpkgs = <nixpkgs>; };

  defaults = import ./modules/defaults.nix;

  eirene = { config, pkgs, ... }: {
    tailscaleServiceContainers = [
      {
        name = "hello";
        serve = "https / http://localhost:80";
      }
      {
        name = "wac-budibase";
        serve = "https / http://localhost:10000";
      }
      {
        name = "omnivore";
        serve = "https / http://localhost:4000";
      }
      {
        name = "wac-plausible";
        serve = "https / http://localhost:8000";
        funnel = "443 on";
      }
    ];
  };
}
