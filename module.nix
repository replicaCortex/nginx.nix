{pkgs, ...}: {
  services = {
    getty = {
      autologinUser = "root";
    };
  };

  system.stateVersion = "24.11";
}
