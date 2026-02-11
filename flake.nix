{
  description = "NixOS flake with Zen Browser + SilentSDDM + Noctalia + QuickShell (fixed)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    zen-browser-flake = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    silent-sddm = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      # Removed the quickshell follows line that caused the warning
    };

    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      
      # This overlay fixes your packages and puts them into 'pkgs'
      myCustomOverlay = final: prev: {
        # 1. Patched QuickShell
        quickshell = inputs.quickshell.packages.${system}.default.overrideAttrs (old: {
          buildInputs = (old.buildInputs or [ ]) ++ [ prev.qt6.qtwayland.dev ];
        });

        # 2. Patched Noctalia (renamed to noctalia-shell for consistency)
        noctalia-shell = inputs.noctalia.packages.${system}.default.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            echo "// Stub SwayService for Niri" > $out/share/noctalia-shell/Services/SwayService.qml
          '';
        });

        # 3. Zen Browser
        zen-browser = inputs.zen-browser-flake.packages.${system}.default;

        # 4. SDDM Theme
        sddmTheme = inputs.silent-sddm.packages.${system}.default;
      };

    in {
      nixosConfigurations."frost" = nixpkgs.lib.nixosSystem {
        inherit system;

        # Passes 'inputs' to configuration.nix
        specialArgs = { inherit inputs; }; 

        modules = [
          # Apply the overlay
          ({ ... }: { nixpkgs.overlays = [ myCustomOverlay ]; })

          ./configuration.nix

          # SDDM Configuration
          ({ pkgs, ... }: {
            environment.systemPackages = [
              pkgs.sddmTheme
              pkgs.noto-fonts
              pkgs.feh
              pkgs.imagemagick
            ];

            qt.enable = true;
            services.displayManager.sddm = {
              enable = true;
              wayland.enable = true;
              package = pkgs.kdePackages.sddm;
              theme = pkgs.sddmTheme.pname;
              extraPackages = pkgs.sddmTheme.propagatedBuildInputs;
              settings = {
                General = {
                  GreeterEnvironment = "QML2_IMPORT_PATH=${pkgs.sddmTheme}/share/sddm/themes/${pkgs.sddmTheme.pname}/components/,QT_IM_MODULE=qtvirtualkeyboard";
                  InputMethod = "qtvirtualkeyboard";
                };
              };
            };
          })
        ];
      };
    };
}
