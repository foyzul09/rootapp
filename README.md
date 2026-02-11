# ❄️ Frost NixOS Configuration

Welcome to my personal **NixOS Flake** repository. This project manages the `frost` system and provides a standalone, ready-to-use package for **RootApp**.

---

## 🚀 RootApp Standalone Package
I have packaged RootApp (AppImage) with its custom icon and desktop entry. You can use it without cloning this entire repository.

### ⚡ Quick Run (Try it now!)



### To add RootApp to your own NixOS system, use this style in your flake.nix:
```bash

inputs = {
  rootapp = {
    url = "github:foyzul09/rootapp";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};

```

### And in your configuration.nix

```bash
environment.systemPackages = [

] ++ [
     inputs.rootapp.packages.${pkgs.system}.default
];
