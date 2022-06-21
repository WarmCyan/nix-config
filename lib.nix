{
  combineFiles = filesArray: builtins.concatStringsSep "\n" (builtins.map (x: builtins.readFile x) filesArray);
  combine = stringsArray: builtins.concatStringsSep "\n" stringsArray;
}
