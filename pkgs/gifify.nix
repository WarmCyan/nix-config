# https://superuser.com/questions/556029/how-do-i-convert-a-video-to-gif-using-ffmpeg-with-reasonable-quality
# https://superuser.com/questions/744823/how-i-could-cut-the-last-7-second-of-my-video-with-ffmpeg

{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "gifify";
  version = "0.1.0";
  description = "Tool to convert a video into a gif without having to remember all of the ffmpeg flags.";
  usage = "gifify [-f 10|--fps 10] [-s 1|--trim-start 1] [-e 1|--trim-end 1] input.mkv output.gif";
  parameters = {
    fps = {
      flags = [ "-f" "--fps" ];
      description = "Framerate of output gif, (10 is the default)";
    };
    trim_start = {
      flags = [ "-s" "--trim-start" ];
      description = "How many seconds to trim off the beginning.";
    };
    trim_end = {
      flags = [ "-e" "--trim-end" ];
      description = "How many seconds to trim off the end.";
    };
  };
  runtimeInputs = [ pkgs.ffmpeg ];
  text = /* bash */ ''

  if [[ "$#" -lt 2 ]]; then
    print_help
    exit
  fi

  input_file=$1
  output_file=$2

  # calculate duration if necessary
  duration_flag=""
  if [[ "''${trim_end-}" != "" ]]; then
    echo -n "Checking video duration..."
    duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "''${input_file}")
    echo "''${duration}"
    duration=$(echo "''${duration} - ''${trim_end} - ''${trim_start-0}" | bc -l)
    duration_flag="-t ''${duration}"
  fi

  cat << EOF
FFMPEG COMMAND:

ffmpeg -i "''${input_file}" -ss ''${trim_start-0} ''${duration_flag} -vf "fps=''${fps-10},split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "''${output_file}"

EOF

  # shellcheck disable=SC2086
  ffmpeg -i "''${input_file}" -ss ''${trim_start-0} ''${duration_flag} -vf "fps=''${fps-10},split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "''${output_file}"
  '';
}
