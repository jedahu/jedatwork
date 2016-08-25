with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "env";
  buildInputs = [caddy emacs nodejs];
  shellHook = ''
    export PATH="$PATH:./node_modules/.bin"
    npm install
  '';
}
