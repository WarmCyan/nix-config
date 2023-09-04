# These are the core cli tools and configs that I _always_ want to have available.
# This is a module! You can tell by the imports!

# TODO: possible packages:
# comma - https://github.com/nix-community/comma (install and run program by prepending ',')
# ipfetch - https://github.com/trakBan/ipfetch (display info about ip loc, useful for checking server logs maybe?)
# amfora - https://github.com/makeworld-the-better-one/amfora (gemini terminal client)
# bombadillo - https://bombadillo.colorfield.space/ (gemini and gopher and other client)

{ pkgs, self, gitUsername, gitEmail, ... }: 
{
  imports = [ 
    ./nvim 
    ./packages.nix
    ./configs.nix
  ];
}
