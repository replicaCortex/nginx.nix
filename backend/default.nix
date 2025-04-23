{pkgs, ...}: let
  pythonEnv = pkgs.python312.withPackages (ps:
    with ps; [
      fastapi
      uvicorn
    ]);
in {
  system.stateVersion = "24.11";

  # --- openssh ---
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.PermitRootLogin = "yes";
  };

  users.users.root.initialPassword = "root";

  virtualisation.forwardPorts = [
    {
      from = "host";
      host.port = 2223;
      guest.port = 22;
    }

    {
      from = "host";
      host.port = 8081;
      guest.port = 8000;
    }
  ];

  # --- pkgs ---
  environment.systemPackages = [pythonEnv];

  # --- UNIT ---
  users.groups.backend = {};
  users.users.backend = {
    group = "backend";
    isSystemUser = true;
    home = "/var/lib/backend";
    createHome = true;
    shell = pkgs.bash;
  };

  systemd.services."backend" = {
    enable = true;
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      User = "backend";
      Group = "backend";
      Restart = "on-failure";
      WorkingDirectory = "/var/www/backend";
      ExecStart = "/run/current-system/sw/bin/uvicorn --reload app:app";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/www/backend 0755 backend backend -"
  ];

  virtualisation.sharedDirectories.backend = {
    source = "$WWW";
    target = "/var/www";
  };
}
