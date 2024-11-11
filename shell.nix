with (import <nixpkgs> {});
let
  gems = bundlerEnv {
    name = "software-technology-mq";
    gemdir = ./.;
  };
in mkShell { packages = [ gems gems.wrappedRuby ]; }
