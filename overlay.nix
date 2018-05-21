self: super: {
  scaleway = {
    source = super.fetchFromGitHub {
      owner = "scaleway";
      repo = "image-tools";
      rev = "1ede07e6a5c87cca4ec975166d393ca78c07b7ff";
      sha256 = "0qj3fy03b28l4cjhil66yd1agfrq32flzxxzm5k35crmr7n5xp9w";
    };
    scw-metadata = super.runCommand "scw-metadata" {} ''
      mkdir -p $out/bin
      cat > $out/bin/scw-metadata /dev/stdin ${self.scaleway.source}/bases/overlay-common/usr/local/bin/scw-metadata <<EOF
      #!${self.stdenv.shell}
      export PATH="${self.curl}/bin:\$PATH"
      EOF
      chmod a+x $out/bin/scw-metadata
    '';
    scw-fetch-ssh-keys = super.runCommand "scw-fetch-ssh-keys" {} ''
      mkdir -p $out/bin
      cat > $out/bin/scw-fetch-ssh-keys <<EOF
      #!${self.stdenv.shell}
      export PATH="${self.scaleway.scw-metadata}/bin:\$PATH"
      EOF
      sed -r 's,/usr/local/s?bin/,,g' ${self.scaleway.source}/bases/overlay-common/usr/local/sbin/scw-fetch-ssh-keys >> $out/bin/scw-fetch-ssh-keys
      chmod a+x $out/bin/scw-fetch-ssh-keys
    '';
  };
}
