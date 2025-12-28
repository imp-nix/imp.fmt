/**
  KDL formatting configuration.

  Provides kdlfmt wrapper with tab indentation enabled by default.
*/
{ pkgs, lib }:
let
  /**
    kdlfmt configuration file with tab indentation.
  */
  configFile = pkgs.writeText "kdlfmt.kdl" ''
    use_tabs #true
  '';
in
{
  /**
    kdlfmt wrapper that passes the config file automatically.

    This ensures consistent formatting with tab indentation without
    requiring a config file in each project.
  */
  wrapper = pkgs.writeShellScriptBin "kdlfmt-wrapper" ''
    exec ${lib.getExe pkgs.kdlfmt} format --config ${configFile} "$@"
  '';

  /**
    Generate treefmt settings for kdlfmt.

    # Arguments

    wrapper
    : The wrapper script derivation.

    # Returns

    Attrset with treefmt formatter configuration for kdlfmt.
    Matches all .kdl files in the project.
  */
  settings = wrapper: {
    kdlfmt = {
      command = "${wrapper}/bin/kdlfmt-wrapper";
      includes = [ "*.kdl" ];
    };
  };
}
