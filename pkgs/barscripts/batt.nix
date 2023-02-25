{ writeShellApplication, pkgs }:
writeShellApplication {
  name = "batt";
  runtimeInputs = [ pkgs.acpi pkgs.gnused ];
  text = /* bash */ ''
    batt=$(acpi | sed -n "s/^.*, \([0-9]*\)%.*/\1/p")

    count=0
    avg=0
    for n in $batt; do
      ((avg+=n))
      ((count+=1))
    done

    avg=$((avg / count))
    battavg=$avg

    if [[ ''${count} -eq 0 ]]; then
      echo " "
    else
      echo "  ''${battavg}%"
      
    fi
  '';
}
