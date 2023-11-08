{ config, lib, ... }: {
  options.tailscaleServiceContainers = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        name = lib.mkOption { type = lib.types.uniq lib.types.str; };
        serve = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        funnel = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      };
    });
    default = [ ];
  };

  config = {
    networking = {
      nat = {
        enable = true;
        internalInterfaces = [ "ve-+" ];
        externalInterface = "eno1";
      };
    };

    system.activationScripts.create-container-bind-mounts =
      "mkdir -p / " # The / ensures the command runs even if there are no containers
      + (builtins.concatStringsSep " "
        (builtins.map (c: c.bindMounts."/var/lib".hostPath)
          (builtins.attrValues config.containers)));

    containers = builtins.listToAttrs (lib.imap1 (index:
      { name, serve, funnel, containers ? { } }: {
        name = name;
        value = let
          address = "172.16.0.${
              toString (100 + index)
            }"; # Use 172.16.x.x network instead of 192.168.1.x used in local network to prevent this from masking any already assigned IPs
        in {
          ephemeral = true;
          autoStart = true;

          localAddress = address;
          hostAddress = "172.16.0.100";
          privateNetwork = true;

          enableTun =
            true; # Necessary for SystemD to be able to start Tailscale. Not necessary if started manually

          systemCallFilter = [
            "add_key"
            "keyctl"
            "bpf"
          ]; # Enable docker support (https://wiki.archlinux.org/title/systemd-nspawn#Run_docker_in_systemd-nspawn)

          bindMounts = {
            "/run/keys" = {
              hostPath = "/run/keys";
              isReadOnly = true;
            };
            "/var/lib" = {
              hostPath = "/mnt/tailscale-service-container-${name}/var/lib";
              isReadOnly = false;
            };
          };

          config = { config, pkgs, lib, ... }: ({
            imports = [ ./networking.nix ];

            system.stateVersion = "23.05";

            services.tailscale.serve = serve;
            services.tailscale.funnel = funnel;

            virtualisation = {
              docker.enable = true;
              oci-containers = {
                backend = "docker";
                containers = containers;
              };
            };
          });
        };
      }) config.tailscaleServiceContainers);
  };

  disabledModules = [ "virtualisation/nixos-containers.nix" ];
  imports = [ ../patches/nixos-containers.nix ];
}
