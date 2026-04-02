{ pkgs, ... }:
{
  programs.openvpn3.enable = true;

  # Configure dnscrypt-proxy to use forwarding rules
  # Format: domain resolver (space-separated, no leading dot)
  services.dnscrypt-proxy.settings.forwarding_rules = "${pkgs.writeText "dnscrypt-forwarding-rules.txt" ''
    default.svc.cluster.local 101.64.0.10
    svc.cluster.local 101.64.0.10
    cluster.local 101.64.0.10
    eu-west-1.compute.internal 101.64.0.10
  ''}";
}

