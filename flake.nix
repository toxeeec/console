{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    openocd-src = {
      url = "github:openocd-org/openocd/2b93ad7c36927f0d2965887857a3213a50b820e6";
      flake = false;
    };
    cmsis-core = {
      url = "github:ARM-software/CMSIS_6/v6.2.0";
      flake = false;
    };
    cmsis-device-n6 = {
      url = "github:STMicroelectronics/cmsis-device-n6/61e652bb08e87f2f0a487b06bec9aa4e8e020b74";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    openocd-src,
    cmsis-core,
    cmsis-device-n6,
    ...
  }: {
    devShells =
      nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ] (system: let
        pkgs = nixpkgs.legacyPackages.${system};
        # pkgs.openocd lacks the STM32N6 target.
        openocd = pkgs.stdenv.mkDerivation {
          name = "openocd-stm32n6";
          src = openocd-src;
          nativeBuildInputs = with pkgs; [autoreconfHook pkg-config texinfo];
          buildInputs = with pkgs; [jimtcl libusb1];
          configureFlags = ["--enable-stlink" "--disable-werror"];
          enableParallelBuilding = true;
        };
      in {
        default = pkgs.mkShell {
          packages = [openocd pkgs.zig];
          CMSIS_CORE_INCLUDE = "${cmsis-core}/CMSIS/Core/Include";
          STM32N6_INCLUDE = "${cmsis-device-n6}/Include";
        };
      });
  };
}
