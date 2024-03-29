{ pkgs, lib, hostname, username, config, ... }:
{
  home.packages = with pkgs; [
    ario
    cantata
  ];
  
  programs.beets = {
    enable = true;
    package = pkgs.beets;
    mpdIntegration.enableUpdate = true;  # mpdupdate plugin
    settings = {
      directory = "~/music";
      import = {
        write = true;
        copy = true;
        move = false;
        autotag = true;
      };
      plugins = [ 
        "embedart" 
        "fetchart" 
        "edit" 
        "mbsync"  # lets you update library based on musicbrainz
        "lyrics"  # get the lyrics and embed them!
        "lastgenre"  # better genre finding
        "replaygain"
        "importfeeds"  # can make playlists based on when you import things
        "smartplaylist"
        "web"  # make a 'beet web' command that lets you browse beets db
      ];
      embedart = {
        auto = true;
      };
      fetchart = {
        auto = true;
      };
      lyrics = {
        auto = true;
        sources = "*";
      };
      lastgenre = {
        auto = true;
        title_case = true;
        count = 3;
        separator = ";";
        source = "track";
        force = false;
      };
      replaygain = {
        auto = true;
        backend = "ffmpeg";
      };
      importfeeds = {
        formats = [ "m3u" "m3u_session" ];
        dir = "~/music_playlists/beets_imports";
        relative_to = "~/music";
      };
      smartplaylist = {
        auto = false;  # need to set these up first
        playlist_dir = "~/music_playlists";
        relative_to = "~/music";
      };
    };
  };
  
  programs.ncmpcpp.enable = true;
  
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/music";
    playlistDirectory = "${config.home.homeDirectory}/music_playlists";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "Pipewire Playback"
      }
    '';
  };
}
