{pkgs, ...}: {
  system.stateVersion = "24.11";

  # --- openssh ---
  environment.systemPackages = with pkgs; [neovim];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.PermitRootLogin = "yes";
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDDXibhZ0XqzBnMB1C7TXgNZMcty2Fvgchvwn7GVTfF replicaCortex@gmail.com"
  ];

  users.users.root.initialPassword = "root";

  virtualisation.forwardPorts = [
    {
      from = "host";
      host.port = 2222;
      guest.port = 22;
    }
  ];
}
