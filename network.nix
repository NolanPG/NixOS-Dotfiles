{ 
  config, 
  libs, 
  pkgs, 
  ... 
}:

{
  # Enabling Wi-Fi
  networking = {
    hostName = "nixos";
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
    wireless.dbusControlled = true;
    wireless.allowAuxiliaryImperativeNetworks = true;

    firewall = {
      allowedTCPPorts = [ 80 443 8080 8081 8000 8001 3000 6600 7201 ];
      allowedUDPPorts = [ 80 443 8080 8081 8000 8001 3000 6600 7201 51820 ];
      allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
      allowedUDPPortRanges = [{ from = 1714; to = 1764; }];
    };

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


    # # Set up Wireguard as a proxy
    # wireguard = { 
    #   enable = true;

    #   interfaces = {
        
    #     wg0 = {
    #       ips = [
    #         "192.168.1.133/24"
    #         "192.168.6.215/32"
    #       ];
    #       listenPort = 51280;
    #       privateKey = "GCzx5re4yvoPmwtNCfchZ/tSDp0cwcqJTjVsDtIvglM=";

    #       peers = [
    #         {
    #           publicKey = "bRlmdNfjTVQSHDON4OQEg9dHaKW2bLXVHOxc88Fd+kM=";
    #           allowedIPs = [
    #             "0.0.0.0/0, ::/0"
    #           ];
    #           endpoint = "pt1.vpnjantit.com:1024";
              
    #           # Send keepalives every 25 seconds. Important to keep NAT tables alive.
    #           persistentKeepalive = 25;
    #         }
    #       ];
    #     };
    #   };
    # };
  };

  # Creating a WiFi HotSpot that launches on startup, note that doesn't appear in Plasma System Tray Network utility
  networking.interfaces.wlan0.useDHCP = true; # DHCP is needed for wlan0 to be visible in other devices
  services.create_ap = {
    enable = true;
    settings = {
      INTERNET_IFACE = "enp8s0";
      WIFI_IFACE = "wlan0";
      SSID = "nolan-nixos";
      PASSPHRASE = "awsqd1e23";
    };
  };

  # Enabling SSH
  services.openssh = {
    enable = true;

    settings.PasswordAuthentication = true;
  };
}