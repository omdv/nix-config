{pkgs, ...}: {
  programs.nixvim.plugins.conform-nvim = {
    enable = true;
    settings = {
      formatters_by_ft = {
        nix = ["alejandra"];
        python = ["ruff_format" "ruff_organize_imports"];
      };
      format_on_save = {
        timeout_ms = 500;
        lsp_fallback = true;
      };
      formatters = {
        alejandra.command = "${pkgs.alejandra}/bin/alejandra";
        ruff_format.command = "${pkgs.unstable.ruff}/bin/ruff";
        ruff_organize_imports.command = "${pkgs.unstable.ruff}/bin/ruff";
      };
    };
  };
}
