#let url = https://www.cs.helsinki.fi/u/tmtynkky/nixos-arm/channel; in
let url = https://mirrors.samueldr.com/nixos-arm/channel; in
{
  nix.binaryCaches = [ url ];
  nix.trustedBinaryCaches = [ url ];
  nix.binaryCachePublicKeys = [
    "nixos-arm.dezgeg.me-1:xBaUKS3n17BZPKeyxL4JfbTqECsT+ysbDJz29kLFRW0=%"
  ];
}
