# see ../../../home/common/minimal-desktop/default.nix for hm-side
{ self, config, configName, lib, hostname, pkgs, ... }:
with lib;
let
  cfg = config.desktop.minimalX;
in
{
  options.desktop.minimalX = {
    enable = mkEnableOption "Minimal xorg DE-less, greeter-less setup";
    termFontsize = mkOption {
      type = types.int;
      default = 28;
      description = "Size of the terminus, terminal font, e.g. 24, 28, 32";
    };
    figletNameColor = mkOption {
      type = types.str;
      default = "1;36";
      description = "The 16color (but only the brighter 8) to use for the name of the machine in the figlet /etc/issue greeting.";
    };
  };

  config = mkIf cfg.enable {

    console = {
      earlySetup = true;
      font = "${pkgs.terminus_font}/share/consolefonts/ter-1${toString cfg.termFontsize}b.psf.gz";
      packages = with pkgs; [ terminus_font ];
      keyMap = "us";
      colors = [
        "282828"
        "cc241d"
        "98971a"
        "d79921"
        "458588"
        "b16286"
        "689d6a"
        "a89984"
        "928374"
        "fb4934"
        "b8bb26"
        "fabd2f"
        "83a598"
        "d3869b"
        "8ec07c"
        "ebdbb2"
      ];
    };
    
    # https://discourse.nixos.org/t/opening-i3-from-home-manager-automatically/4849/13
    # https://discourse.nixos.org/t/how-to-start-i3-using-greetd/28028
    # https://discourse.nixos.org/t/how-to-create-a-timestamp-in-a-nix-expression/30329

    environment.etc = {
      "issue".source = pkgs.writeText "issue" ''

=============================================================${lib.readFile "${pkgs.runCommand "colorecho" {} "echo -en \"\\033[${cfg.figletNameColor}m\" > $out" }"}
${lib.replaceStrings ["\\"] ["\\\\"] (lib.readFile "${pkgs.runCommandWith { name="gen_name"; derivationArgs.nativeBuildInputs = [ pkgs.figlet ]; } "figlet -f cyberlarge ${hostname} > $out"}")}${lib.readFile "${pkgs.runCommand "colorecho" {} "echo -en \"\\033[0m\" > $out" }"}=============================================================

${configName}:${builtins.substring 0 4 self.lastModifiedDate}-${builtins.substring 4 2 self.lastModifiedDate}-${builtins.substring 6 2 self.lastModifiedDate}:${builtins.substring 8 100 self.lastModifiedDate} - (\s \m \r) \l

'';
    };
    
    services.xserver = {
      enable = true;
      displayManager.startx.enable = true;
      # everything else (xinitrc, xsession stuff) gets set home-manager side.
    };
  };
}
