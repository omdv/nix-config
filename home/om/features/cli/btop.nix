{...}: {
  programs.btop = {
    enable = true;
    settings = {
      # Appearance
      color_theme = "Default";
      rounded_corners = true;

      # Behaviour
      vim_keys = true;
      update_ms = 1000;

      # CPU
      show_coretemp = true;
      temp_scale = "celsius";
      cpu_single_graph = false;
      cpu_sensor = "Auto";

      # Processes
      proc_tree = true;
      proc_sort = "cpu lazy";
      proc_reversed = true;
      proc_per_core = true;

      # Memory
      mem_graphs = true;
      show_swap = true;

      # Misc
      base_10_sizes = false;
      clock_format = "%H:%M";
    };
  };
}
