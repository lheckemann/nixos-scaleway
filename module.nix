{ pkgs, lib, ... }:
{
  config = {
    nixpkgs.overlays = [(import ./overlay.nix)];
    environment.systemPackages = builtins.attrValues pkgs.scaleway;
    systemd.services.scw-ssh-keys = {
      wantedBy = ["multi-user.target"];
      requires = ["network.target"];
      after = ["network.target"];
      serviceConfig = {
        ExecStart = "${pkgs.scaleway.scw-fetch-ssh-keys}/bin/scw-fetch-ssh-keys";
        Type = "oneshot";
      };
    };
    systemd.timers.scw-ssh-keys = {
      wantedBy = ["multi-user.target"];
      timerConfig.OnCalendar = "daily";
    };
  };
}
