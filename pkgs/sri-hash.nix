{ builders }:
builders.writeTemplatedShellApplication {
  name = "sri-hash";
  description = "Quickly get the sri hash from the passed .tar.gz archive link for the source code release from a github repo";
  usage = "sri-hash [ARCHIVE_URL]";
  text = /* bash */ ''

    if [[ $# -lt 1 ]]; then
      echo "Please provide the url to an archive/.tar.gz file of the source." 
      exit 1
    fi
  
    sha256=$(nix-prefetch-url --unpack "$1")
    nix hash to-sri "sha256:$sha256"
  '';
}
