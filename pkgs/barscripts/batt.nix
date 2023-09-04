{ writeShellApplication, pkgs }:
writeShellApplication {
  name = "batt";
  runtimeInputs = [ pkgs.acpi pkgs.gnused ];
  text = /* bash */ ''
    batt=$(acpi 2> /dev/null | sed -n "s/^.*, \([0-9]*\)%.*/\1/p")

    count=0
    avg=0
    for n in $batt; do
      ((avg+=n))
      ((count+=1))
    done

    if [[ ''${count} -eq 0 ]]; then
      echo ""
    else
      avg=$((avg / count))
      battavg=$avg
      echo "  ''${battavg}%"
    fi
  '';
}
