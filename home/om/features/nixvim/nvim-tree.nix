{
  programs.nixvim = {
    plugins.nvim-tree = {
      enable = true;
      openOnSetup = true;
      openOnSetupFile = true;
      settings.auto_reload_on_write = true;
    };
  };
}
