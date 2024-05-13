{
  pkgs,
  lib,
  user,
  ...
}:

{
    environment.systemPackages = with pkgs; [
    bottles # Wine manager
    ryujinx # Nintendo Switch emulator
    sunshine # Remote gaming solution for streaming games over the internet
    goverlay
    mangohud # Performance monitoring tool for Vulkan and OpenGL games
    osu-lazer-bin
    protonup-qt
    winetricks
    wineWowPackages.waylandFull
    obs-studio
    kdePackages.kdenlive
  ];

  # RGB Configuration
  services.hardware.openrgb.enable = true;
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];

  hardware = {
    steam-hardware.enable = true;
    # xpadneo.enable = true;
  };

  # Enable gamemode
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        softrealtime = "auto";
        renice = 10;
      };
      custom = {
        start = "notify-send -a 'Gamemode' 'Optimizations activated'";
        end = "notify-send -a 'Gamemode' 'Optimizations deactivated'";
      };
    };
  };

  # improvement for games using lots of mmaps (same as steam deck)
  boot.kernel.sysctl = {"vm.max_map_count" = 2147483642;};

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  #Enable Gamescopep
  programs.gamescope = {
    enable = true;
    package = pkgs.gamescope;
    capSysNice = true;
    args = ["--prefer-vk-device 1002:73ff"];
    env = {
      "__GLX_VENDOR_LIBRARY_NAME" = "amd";
      "DRI_PRIME" = "1";
      "MESA_VK_DEVICE_SELECT" = "pci:1002:73ff";
      "__VK_LAYER_MESA_OVERLAY_CONFIG" = "ld.so.preload";
      "DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1" = "1";
    };
  };
}
