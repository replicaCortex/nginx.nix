{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    nixpkgs.url = "github:NixOS/nixpkgs/24.11";
  };

  outputs = {
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      mkVM = configuration:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {inherit pkgs;};
          modules = [
            ({modulesPath, ...}: {
              imports = ["${modulesPath}/virtualisation/qemu-vm.nix"];
              virtualisation = {
                graphics = false;
                diskImage = null;
              };
            })
            configuration
          ];
        };

      frontend = mkVM ./frontend/default.nix;
      backend = mkVM ./backend/default.nix;

      program = pkgs.writeShellScript "run-vm.sh" ''
        export FRONTEND_VM="${frontend.config.system.build.vm}"
        export BACKEND_VM="${backend.config.system.build.vm}"
        exec ${./run-vm.sh}
      '';

      pythonEnv = pkgs.python312.withPackages (ps:
        with ps; [
          pytest
          gunicorn
          fastapi
        ]);
    in {
      packages = {
        default = program;
      };

      apps.default = {
        type = "app";
        program = "${program}";
      };

      devShell = pkgs.mkShell {
        buildInputs = [pythonEnv];
        shellHook = ''
          export PYTHONPATH="${pythonEnv}:$PYTHONPATH:${pythonEnv}/${pythonEnv.sitePackages}"
          exec zsh
        '';
      };
    });
}
