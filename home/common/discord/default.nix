{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # https://github.com/Misterio77/nix-config/blob/main/home/misterio/features/desktop/common/discord.nix
    discord
    discocss
  ];


  xdg.configFile."discocss/custom.css".text = /* css */ ''
    .theme-dark {
      --header-primary: #FF9866;
      --header-secondary: #343332;
      --text-normal: #d4be98;

      --background-primary: #151414;
      --background-secondary: #222121;
    }
    '';
}
