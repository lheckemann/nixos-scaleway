let url = https://lugn.sphalerite.org/cache; in {
  nix = {
    binaryCaches = [ url ];
    trustedBinaryCaches = [ url ];
    binaryCachePublicKeys = [
      "lugn:0tvkqzfliXZSCfsGwi8BSTYMmMIDwGKRkI69sQDux3k="
      "green:Cm0baEzipGtHM7IgoDXjd/3b94zwx2JfxHrHTm2j50A="
      "arm1:RnI+q/+YRndhrhuOh4MdU7U6NEaYWCz0BnpRYZ+hhh8="
    ];
  };
}

