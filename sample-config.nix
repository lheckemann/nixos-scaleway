{ pkgs, ... }: {
  imports = [ ./bincache-lugn.nix ./bincache-dezgeg.nix ./module.nix ];
  system.nixos.stateVersion = "18.03";

  environment.systemPackages = with pkgs; [vim tmux git strace lsof];

  nix.maxJobs = 4;
  boot.loader.initScript.enable = true;
  boot.loader.grub.enable = false;
  users.users.root.openssh.authorizedKeys.keyFiles = [(builtins.fetchurl https://sphalerite.org/yubi.pub)];
  services.openssh.enable = true;
  services.openssh.extraConfig = ''
    # Reuse default key from ubuntu
    HostKey /etc/ssh/ssh_host_ecdsa_key
  '';
  services.mingetty.serialSpeed = [ 9600 ];

  systemd.services.systemd-vconsole-setup.enable = false;
  boot.kernelParams = ["earlyprintk=ttyS0" "console=ttyS0,9600n8" "nousb" "nbd.max_part=16"];
  boot.kernelModules = ["nbd"];
  fileSystems."/" = {
    device = "/dev/nbd0";
    fsType = "ext4";
  };
  # These machines lock up very easily when running out of RAM, since
  # the storage is on the network. So we kill processes before that
  # happens.
  services.earlyoom.enable = true;
  services.earlyoom.freeMemThreshold = 5;
  boot.initrd.network.enable = true;
  boot.initrd.postDeviceCommands = ''
    ${pkgs.curl}/bin/curl -o /metadata http://169.254.42.42/conf
    . /metadata
    noscheme="''${VOLUMES_0_EXPORT_URI#nbd://"
    ip="''${noscheme%:*}"
    port="''${noscheme##*:"
    ( exec -a @xnbd-client ${pkgs.xnbd}/bin/xnbd-client --blocksize 4096 --retry=900 "$ip" "$port" /dev/nbd0 )
  '';
}
