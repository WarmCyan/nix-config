{
  combineFiles = filesArray: builtins.concatStringsSep "\n" (builtins.map (x: builtins.readFile x) filesArray);
  
  combine = stringsArray: builtins.concatStringsSep "\n" stringsArray;
  # couldn't get it to work
  #combine = stringsArray: builtins.concatStringsSep "\n" (builtins.map (x: if builtins.isFunction x then (x) else x) stringsArray);
}
