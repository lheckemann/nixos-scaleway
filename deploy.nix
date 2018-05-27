{ configuration ? ./sample-config.nix }:
let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib nix writeScript stdenv;
  system = (import <nixpkgs/nixos> { inherit configuration; }).config.system.build.toplevel;
  closure-info = pkgs.closureInfo { rootPaths = [system]; };
  path = lib.makeBinPath (with pkgs; [openssh pv gnutar coreutils nix]);
in {
  send-script = writeScript "send" ''
    #!${stdenv.shell}
    set -xe
    [[ -d $XDG_RUNTIME_DIR ]]
    export PATH=${path}
    TMP=$(mktemp -d "$XDG_RUNTIME_DIR/nixos-deploy-XXXXXX")
    trap "rm -rf $TMP" exit
    sshopts="-o ControlPath=$TMP/ssh-control -C"
    ssh $sshopts -o ControlMaster=yes -o ControlPersist=60 "$1" true
    remote() {
      ssh $sshopts "$1" "$@"
    }
    closureSize=$(nix path-info -S ${system} | cut -d $'\t' -f 2)
    tar c $(nix-store -qR ${system}) | pv -s $closureSize | remote "cd /; tar x"
    cat ${closure-info}/registration | remote "${nix}/bin/nix-store --load-db"
    remote "addgroup --system nixbld"
    remote "adduser --system --ingroup nixbld --home /homeless-shelter --disabled-password --no-create-home nixbld1"
    remote "adduser nixbld1 nixbld"
    remote "${nix}/bin/nix-channel --add https://nixos.org/channels/nixos-unstable nixos"
    remote "${nix}/bin/nix-env -p /nix/var/nix/profiles/system --set ${system}"
    remote "find /etc -not -name 'ssh_host_*' -delete ; touch /etc/NIXOS"
    remote "rm -f /root/.bashrc /root/.profile"
    remote "${system}/activate ; ${system}/bin/switch-to-configuration switch"
    remote "rm -rf /bin /usr /media /opt /sbin /srv /var/{backups,cache,lib/{apt,dhcp,dpkg,logrotate,man-db,misc,ntp,ntpdate,pam,python,sudo,ucf,vim}}"
    tar c ${./.} | remote "mkdir -p /etc/nixos ; cd /etc/nixos ; tar x"
  '';
}
