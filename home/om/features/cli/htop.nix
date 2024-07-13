{
  config,
  ...
}: {
  programs.htop = {
    enable = true;
    settings = {
      # htop settings
      color_scheme=0;
      enable_mouse=1;
      delay=15;
      hide_kernel_threads=1;
      hide_userland_threads=0;
      hide_running_in_container=0;
      shadow_other_users=0;
      show_thread_names=0;
      show_program_path=1;
      degree_fahrenheit=0;
      update_process_names=0;
      account_guest_in_cpu_meter=0;
      highlight_base_name=0;
      highlight_deleted_exe=1;
      shadow_distribution_path_prefix=0;
      highlight_megabytes=1;
      highlight_threads=1;
      highlight_changes=0;
      highlight_changes_delay_secs=5;
      find_comm_in_cmdline=1;
      strip_exe_from_cmdline=1;
      show_merged_command=0;
      screen_tabs=1;
      hide_function_bar=0;
      # cpus
      detailed_cpu_time=0;
      cpu_count_from_one=1;
      show_cpu_usage=1;
      show_cpu_frequency=1;
      show_cpu_temperature=1;
      # tree view
      tree_view=1;
      sort_key=46;
      tree_sort_key=0;
      sort_direction=-1;
      tree_sort_direction=1;
      tree_view_always_by_pid=0;
      all_branches_collapsed=1;
      # fields
      fields = with config.lib.htop.fields; [
        PID
        USER
        PRIORITY
        NICE
        M_SIZE
        M_RESIDENT
        M_SHARE
        STATE
        PERCENT_CPU
        PERCENT_MEM
        TIME
        COMM
      ];
      # headers
      header_layout="two_50_50";
      header_margin=1;
    } // (with config.lib.htop; leftMeters [
      (bar "AllCPUs")
      (bar "Memory")
      (bar "Swap")
    ]) // (with config.lib.htop; rightMeters [
      (text "Uptime")
      (text "Blank")
      (text "Tasks")
      (text "Systemd")
      (text "SystemdUser")
      (text "Blank")
      (text "DiskIO")
      (text "FileDescriptors")
      (text "Blank")
      (text "NetworkIO")
    ]);
  };
}
