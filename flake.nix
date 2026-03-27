{
  description = "Standalone RootApp package - No system dependencies";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = rec {
        # The main package definition
        rootapp = pkgs.appimageTools.wrapType2 {
          pname = "rootapp";
          version = "latest";
          src = pkgs.fetchurl {
            url = "https://installer.rootapp.com/installer/Linux/X64/Root.AppImage";
            sha256 = "sha256-RQvSbkcy9OHj9GfqnxXMc1VfM1XUI+NO+ap+M96BtAM=";
          };

          extraInstallCommands = ''
            # Create icon directory and copy the bundled PNG
            mkdir -p $out/share/icons/hicolor/256x256/apps
            cp ${./rootapp.png} $out/share/icons/hicolor/256x256/apps/rootapp.png

            # Create the Desktop Entry
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

        # Set default so 'nix run' and 'nix build' work out of the box
        default = rootapp;
      };
    };
}
