/**
  Markdown formatting configuration.

  Provides mdformat package with plugins and treefmt settings for
  formatting Markdown files with GitHub Flavored Markdown, frontmatter,
  and footnote support.
*/
{ pkgs, lib }:
{
  /**
    mdformat package with required plugins.

    Includes:
    - mdformat-gfm: GitHub Flavored Markdown
    - mdformat-frontmatter: YAML frontmatter
    - mdformat-footnote: Footnote syntax
  */
  package = pkgs.mdformat.withPlugins (
    ps: with ps; [
      mdformat-gfm
      mdformat-frontmatter
      mdformat-footnote
    ]
  );

  /**
    Generate treefmt settings for mdformat.

    # Arguments

    mdformatPkg
    : The mdformat package with plugins.

    # Returns

    Attrset with treefmt formatter configuration for mdformat.
  */
  settings = mdformatPkg: {
    mdformat = {
      command = lib.getExe mdformatPkg;
      includes = [ "*.md" ];
    };
  };
}
