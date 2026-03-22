{...}: {
  programs.nixvim.plugins.lsp = {
    enable = true;
    servers = {
      # Nix — points at the local flake for accurate option completions
      nixd = {
        enable = true;
        settings = {
          nixpkgs.expr = "import <nixpkgs> {}";
          options = {
            nixos.expr = "(builtins.getFlake \"/home/om/nix-config\").nixosConfigurations.framework.options";
            home_manager.expr = "(builtins.getFlake \"/home/om/nix-config\").homeConfigurations.\"om@framework\".options";
          };
        };
      };

      # Python
      pyright.enable = true;
    };

    keymaps = {
      lspBuf = {
        "gd" = {
          action = "definition";
          desc = "Go to definition";
        };
        "gD" = {
          action = "declaration";
          desc = "Go to declaration";
        };
        "gr" = {
          action = "references";
          desc = "Go to references";
        };
        "gi" = {
          action = "implementation";
          desc = "Go to implementation";
        };
        "K" = {
          action = "hover";
          desc = "Hover docs";
        };
        "<leader>rn" = {
          action = "rename";
          desc = "Rename symbol";
        };
        "<leader>ca" = {
          action = "code_action";
          desc = "Code action";
        };
        "<leader>lf" = {
          action = "format";
          desc = "Format buffer";
        };
      };
      diagnostic = {
        "<leader>d" = {
          action = "open_float";
          desc = "Show diagnostics";
        };
        "[d" = {
          action = "goto_prev";
          desc = "Previous diagnostic";
        };
        "]d" = {
          action = "goto_next";
          desc = "Next diagnostic";
        };
      };
    };
  };
}
