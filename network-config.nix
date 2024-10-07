# network-config.nix
{
  networkConfig = rec {
    appTraffic = {
      name = "app-network";
      vlanId = 100;
      subnet = "10.1.0.0";
      cidr = 16;
      gateway = "10.1.0.1";
      dhcpRange = {
        start = "10.1.0.20";
        end = "10.1.254.254";
      };
      internetAccess = true;
      nat = true;
    };

    k3sApi = {
      name = "k3s-api-network";
      vlanId = 200;
      subnet = "10.200.0.0";
      cidr = 16;
      dhcpRange = {
        start = "10.200.0.20";
        end = "10.200.255.254";
      };
      internetAccess = false;
      nat = false;
    };

    storage = {
      name = "storage-network";
      vlanId = 300;
      subnet = "10.45.0.0";
      cidr = 16;
      gateway = "10.45.0.1";
      dhcpRange = {
        start = "10.45.0.20";
        end = "10.45.255.254";
      };
      internetAccess = false;
      nat = false;
      jumboFrames = {
        enabled = true;
        mtu = 9000;
      };
    };

    globalSettings = {
      dnsServers = [
        "8.8.8.8"
        "8.8.4.4"
      ];
      ntpServers = [
        "pool.ntp.org"
      ];
    };
  };
}