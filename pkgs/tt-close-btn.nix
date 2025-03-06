{ lib, stdenv, fetchgit, tt-rss }:

stdenv.mkDerivation {
  pname = "tt-rss-plugin-close-button";
  version = "0.01";

  src = fetchgit {
    url = "https://git.tt-rss.org/fox/ttrss-close-button.git/";
    rev = "5ea48521b98a082795eb35fa22ab0e22aa35f72f";
    sha256 = "sha256-Uap5ulBz8q0I6hlgETRdy5XS02XYhh7bjqOO6qWwPGc=";
  };

  installPhase = ''
    mkdir -p $out/close_button
    cp -r init.php $out/close_button
  '';
}
