{pkgs, ...}: {
  config = {
    system.stateVersion = "24.11";

    # --- OPENSSH ---
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = true;
      settings.PermitRootLogin = "yes";
    };

    users.users.root.initialPassword = "root";

    virtualisation.forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }

      {
        from = "host";
        host.port = 8080;
        guest.port = 80;
      }
    ];

    # --- NGINX ---
    users.groups.frontend = {};
    users.users.frontend = {
      group = "frontend";
      isSystemUser = true;
      home = "/var/lib/frontend";
      createHome = true;
      shell = pkgs.bash;
    };

    networking.firewall.allowedTCPPorts = [80];

    services = {
      nginx = {
        enable = true;

        virtualHosts.localhost.locations."/" = {
          index = "/templates/index.html";
          root = "/var/www";
        };
      };
    };

    virtualisation.sharedDirectories.frontend = {
      source = "$WWW/frontend/www";
      target = "/var/www";
    };
  };
}
