{ pkgs, ... }:

let
  # Define the package
  rootapp-pkg = pkgs.appimageTools.wrapType2 {
    pname = "rootapp";
    version = "latest";

    src = pkgs.fetchurl {
      url = "https://installer.rootapp.com/installer/Linux/X64/Root.AppImage";
      sha256 = "1xd5lqgljm6s4zpwmbnllbf3lbn1b4f2l85z26i2k6ycfwywghhz";
    };

    extraInstallCommands = ''
      # Install the icon
      mkdir -p $out/share/icons/hicolor/256x256/apps
      cp ${./rootapp.png} $out/share/icons/hicolor/256x256/apps/rootapp.png

      # Create the desktop launcher
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
in
{
  # Tell Nix to add this package to the system profile
  environment.systemPackages = [ rootapp-pkg ];
}
