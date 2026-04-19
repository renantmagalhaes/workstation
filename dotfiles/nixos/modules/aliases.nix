#{ pkgs, ... }:
#
#{
#  environment.systemPackages = [
#    # swww was renamed to awww — shim both binaries for script compatibility
#    (pkgs.writeShellScriptBin "swww" ''exec ${pkgs.awww}/bin/awww "$@"'')
#    (pkgs.writeShellScriptBin "swww-daemon" ''exec ${pkgs.awww}/bin/awww-daemon "$@"'')
#  ];
#}
