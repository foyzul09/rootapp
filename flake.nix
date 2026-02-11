{
  description = "NixOS flake with Zen Browser + SilentSDDM + Noctalia + QuickShell + RootApp";

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
    };

    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # --- ROOTAPP PACKAGE DEFINITION ---
      # This is defined here so it can be exported to others AND used in your system
      rootapp = pkgs.appimageTools.wrapType2 {
        pname = "rootapp";
        version = "latest";
        src = pkgs.fetchurl {
          url = "https://installer.rootapp.com/installer/Linux/X64/Root.AppImage";
          sha256 = "1xd5lqgljm6s4zpwmbnllbf3lbn1b4f2l85z26i2k6ycfwywghhz";
        };
        extraInstallCommands = ''
          mkdir -p $out/share/icons/hicolor/256x256/apps
          cp ${./rootapp.png} $out/share/icons/hicolor/256x256/apps/rootapp.png
          mkdir -p $out/share/applications
          echo "[Desktop Entry]
          Type=Application
          Name=RootApp
          Exec=rootapp
          Icon=rootapp
          Comment=Root Field Service Management
          Categories=Utility;
          Terminal=false;" > $out/share/applications/rootapp.desktop
        '';
      };

      # --- OVERLAYS ---
      myCustomOverlay = final: prev: {
        # 1. Patched QuickShell
        quickshell = inputs.quickshell.packages.${system}.default.overrideAttrs (old: {
          buildInputs = (old.buildInputs or [ ]) ++ [ prev.qt6.qtwayland.dev ];
        });

        # 2. Patched Noctalia
        noctalia-shell = inputs.noctalia.packages.${system}.default.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            echo "// Stub SwayService for Niri" > $out/share/noctalia-shell/Services/SwayService.qml
          '';
        });

        # 3. Zen Browser
        zen-browser = inputs.zen-browser-flake.packages.${system}.default;

        # 4. SDDM Theme
        sddmTheme = inputs.silent-sddm.packages.${system}.default;

        # 5. Add RootApp to the overlay so it's available as pkgs.rootapp
        rootapp = rootapp;
      };

    in {
      # --- EXPORT FOR OTHERS ---
      # This allows someone to run 'nix run github:foyzul09/rootapp'
        packages.${system} = {
  default = rootapp;
  rootapp = rootapp;
};

      # --- YOUR SYSTEM CONFIGURATION ---
      nixosConfigurations."frost" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; }; 

        modules = [
          ({ ... }: { nixpkgs.overlays = [ myCustomOverlay ]; })

          ./configuration.nix

          # Add rootapp to your system packages
          ({ pkgs, ... }: {
            environment.systemPackages = [ pkgs.rootapp ];
          })

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
