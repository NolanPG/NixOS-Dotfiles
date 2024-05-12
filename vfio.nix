{ pkgs, lib, config, ... }:



let
  # RX 6650 XT
  gpuIDs = [
    "1002:73ef" # Graphics
    "1002:ab28" # Audio
  ];
in {

  options.vfio.enable = with lib;
    mkEnableOption "Configure the machine for VFIO";

  config = let cfg = config.vfio; in {
    boot = {
      initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
      ];

      kernelParams = [
        # enable IOMMU
        "amd_iommu=on"
      ] ++ lib.optional cfg.enable
        # isolate the GPU
        ("vfio-pci.ids=" + lib.concatStringsSep "," gpuIDs);
    };

    hardware.opengl.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
  };

  # Added libvirtd and apps for the virtual machine in configuration.nix
}