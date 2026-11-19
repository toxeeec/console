{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.openocd-src = {
    url = "github:openocd-org/openocd/2b93ad7c36927f0d2965887857a3213a50b820e6";
    flake = false;
  };

  outputs = { nixpkgs, openocd-src, ... }: {
    devShells = nixpkgs.lib.genAttrs [
      "aarch64-darwin" "aarch64-linux" "x86_64-linux"
    ] (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      # pkgs.openocd lacks the STM32N6 target.
      openocd = pkgs.stdenv.mkDerivation {
        name = "openocd-stm32n6";
        src = openocd-src;
        nativeBuildInputs = with pkgs; [ autoreconfHook pkg-config texinfo ];
        buildInputs = with pkgs; [ jimtcl libusb1 ];
        configureFlags = [ "--enable-stlink" "--disable-werror" ];
        enableParallelBuilding = true;
      };
    in { default = pkgs.mkShell { packages = [ openocd pkgs.zig ]; }; });
  };
}
