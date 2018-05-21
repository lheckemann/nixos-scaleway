{ pkgs, lib, ... }:
{
  config = {
    nixpkgs.overlays = [(import ./overlay.nix)];
    systemd.services.scw-ssh-keys = {
      wantedBy = ["multi-user.target"];
      requires = ["networking.target"];
      after = ["networking.target"];
      serviceConfig = {
        ExecStart = "${pkgs.scw-fetch-ssh-keys}/bin/scw-fetch-ssh-keys";
        Type = "oneshot";
      };
    };
    systemd.timers.scw-ssh-keys = {
      wantedBy = ["multi-user.target"];
      timerConfig.OnCalendar = "daily";
    };
  };
}
