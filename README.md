[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

# Local Configuration

Can have non-tracked custom local changes to zsh and bash via:
* `~/.bashrc_local`
* `~/.zshrc_local`

Interactive shell startup welcome stuff can go in `~/.home`
and any additional paths to be added (such as bin paths) can go in
`~/.shell_additional_path`


# Commands

To "run" a given configuration:

```
home-manager switch --flake .#[SYSTEMNAME] --impure
```
