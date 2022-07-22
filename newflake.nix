# (2022/07/20) Recreating this flake based on misterio's as it has many of the
# elements I'm looking for: https://github.com/Misterio77/nix-config
# TODO: he has a bunch of cool looking nix tools listed:
# https://github.com/Misterio77/nix-config/blob/main/home/misterio/cli/default.nix
#
# (2022/07/21) NOTE: we can have each home-manager config have its own dedicated
# folder in home too, if we want to specify individual machine stuff without
# trying to figure out how to do a ton of abstraction

# QUESTIONS
# ===============================
#   - He has custom pkgs, but how does he reference them/pull them in?
#   A: ahhh, I believe he does it in overlay/default.nix at the end, the // ../pkgs
#
#   - Where does he pull in the features? lib.mkHome only puts them into
#   "extraSpecialArgs" along with some modules.
#   A: Inside home/misterio/default, he has an imports list that concats a map
#   with the features list (this "imports" is what makes it a "module", and it
#   is notably importing other modules)
#
#   - How do modules work, do they just automagically append everything when
#   multiple modules are all assigning to the same thing?
#   A: Yeah I think so, in https://nixos.wiki/wiki/Module in "under the hood",
#   they mention that for each option they collect all definitions from all
#   modules and merge them together according to options type.
#   NOTE: so this means we could probably have things like vim plugins/settings
#   modularized too? (e.g. I don't want javascript linters clogging up my system
#   if I have no intention of developing javascript on that system.)
#   NOTE: also, I can probably nest folders like misterio but also have default
#   in top level, so you can either auto import everything by specifying the top
#   level feature, or specify only select things.
#
#   - Wait, where's the "laptop" module? He mentions in /home/misterio/default
#   "import features _that have modules_, are there features that don't?
#
#   - How do we get those other elements put into extraSpecialArgs? 
#   A: They are passed as arguments to each module, so the beginning { ... }
#   function def line.
#
#   - How do I get access to my library functions deep within modules?
#   A: It's somehow still an argument being passed around.

{
    description = "My awesome-sauce and cool-beans nix configuration-y things.";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager/release-22.05";
            inputs.nixpkgs.follows = "nixpkgs"; # unsure what this actually does
        };

        # TODO: add in nix-colors! 
    };

    outputs = inputs:
        let
            lib = import ./lib { inherit inputs; };
}
