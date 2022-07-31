{ parameters ? null }:
{
  result = 
  builtins.concatStringsSep "\n" 
  (builtins.attrValues
  (if parameters != null then 
  builtins.mapAttrs (name: param: 
  ''
    ${builtins.concatStringsSep " | " param.flags})
      ${if param ? option && param.option then
        "${name}=true"
      else
        "${name}=\$1\n  shift"}
        ;;
  ''
  ) parameters 
  else ""));
}
