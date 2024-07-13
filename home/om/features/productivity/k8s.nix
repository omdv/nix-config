# everything related to k8s goes here
{ pkgs, ... }: {
  # misc k8s tools
  home.packages = with pkgs; [
    kubectl
    kubecolor
    dive
  ];
  # k9s
  programs.k9s = {
    enable = true;
    aliases = {
      aliases = {
        dp = "deployments";
        sec = "v1/secrets";
        jo = "jobs";
        cr = "clusterroles";
        crb = "clusterrolebindings";
        ro = "roles";
        rb = "rolebindings";
        np = "networkpolicies";
      };
    };
    hotkey = {
      hotKeys = {
        shift-0 = {
          shortCut = "Shift-0";
          description = "Viewing pods";
          command = "pods";
        };
        shift-1 = {
          shortCut = "Shift-1";
          description = "View deployments";
          command = "dp";
        };
        shift-2 = {
          shortCut = "Shift-2";
          description = "View statefulsets";
          command = "statefulset";
        };
        shift-3 = {
          shortCut = "Shift-3";
          description = "View services";
          command = "service";
        };
      };
    };
    views = {
      views = {
        "v1/pods" = {
          columns = [
            "NAMESPACE"
            "NAME"
            "READY"
            "RESTARTS"
            "CPU"
            "%CPU/L"
            "MEM"
            "%MEM/L"
            "IP"
            "PORTS"
          ];
        };
      };
    };
    plugin = {
      plugins = {
        dive = {
          shortCut = "d";
          confirm = false;
          description = "Dive image";
          scopes = [
            "containers"
          ];
          command = "dive";
          background = false;
          args = [
            "$COL-IMAGE"
          ];
        };
      };
    };

    settings = {
      k9s = {
        liveViewAutoRefresh = false;
        refreshRate = 2;
        maxConnRetry = 5;
        enableMouse = false;
        enableImageScan = false;
        headless = false;
        logoless = false;
        crumbsless = false;
        readOnly = false;
        noExitOnCtrlC = false;
        shellPod = {
          image = "busybox:1.35.0";
          namespace = "default";
          limits = {
        cpu = "100m";
        memory = "100Mi";
          };
        };
        skipLatestRevCheck = false;
        logger = {
          tail = 100;
          buffer = 5000;
          sinceSeconds = 60;
          fullScreenLogs = false;
          textWrap = false;
          showTime = false;
        };
        keepMissingClusters = false;
        clusters = {
          default = {
            namespace = {
              active = "all";
              lockFavorites = false;
              favorites = [
                "apps"
                "ibkr"
                "nocodb"
                "all"
                "default"
              ];
            };
            view = {
              active = "portforward";
            };
            featureGates = {
              nodeShell = false;
            };
            portForwardAddress = "localhost";
          };
        };
        thresholds = {
          cpu = {
            critical = 90;
            warn = 70;
          };
          memory = {
            critical = 90;
            warn = 70;
          };
        };
        screenDumpDir = "/tmp/k9s-screens-om";
        disablePodCounting = false;
      };
    };
    skins = {
      k9s = {
        # General K9s styles
        body = {
          fgColor = "#f8f8f2";
          bgColor = "#282a36";
          logoColor = "#bd93f9";
        };
        # Command prompt styles
        prompt = {
          fgColor = "#f8f8f2";
          bgColor = "#282a36";
          suggestColor = "#bd93f9";
        };
        # ClusterInfoView styles.
        info = {
          fgColor = "#ff79c6";
          sectionColor = "#f8f8f2";
        };
        # Dialog styles.
        dialog = {
          fgColor = "#f8f8f2";
          bgColor = "#282a36";
          buttonFgColor = "#f8f8f2";
          buttonBgColor = "#bd93f9";
          buttonFocusFgColor = "#f1fa8c";
          buttonFocusBgColor = "#ff79c6";
          labelFgColor = "#ffb86c";
          fieldFgColor = "#f8f8f2";
        };
        frame = {
          # Borders styles.
          border = {
            fgColor = "#44475a";
            focusColor = "#44475a";
          };
          menu = {
            fgColor = "#f8f8f2";
            keyColor = "#ff79c6";
            # Used for favorite namespaces
            numKeyColor = "#ff79c6";
          };
          # CrumbView attributes for history navigation.
          crumbs = {
            fgColor = "#f8f8f2";
            bgColor = "#44475a";
            activeColor = "#44475a";
          };
          # Resource status and update styles
          status = {
            newColor = "#8be9fd";
            modifyColor = "#bd93f9";
            addColor = "#50fa7b";
            errorColor = "#ff5555";
            highlightColor = "#ffb86c";
            killColor = "#6272a4";
            completedColor = "#6272a4";
          };
          # Border title styles.
          title = {
            fgColor = "#f8f8f2";
            bgColor = "#44475a";
            highlightColor = "#ffb86c";
            counterColor = "#bd93f9";
            filterColor = "#ff79c6";
          };
        };
        views = {
          # Charts skins...
          charts = {
            bgColor = "default";
            defaultDialColors = [
              "#bd93f9"
              "#ff5555"
            ];
            defaultChartColors = [
              "#bd93f9"
              "#ff5555"
            ];
          };
          # TableView attributes.
          table = {
            fgColor = "#f8f8f2";
            bgColor = "#282a36";
            # Header row styles.
            header = {
              fgColor = "#f8f8f2";
              bgColor = "#282a36";
              sorterColor = "#8be9fd";
            };
          };
          # Xray view attributes.
          xray = {
            fgColor = "#f8f8f2";
            bgColor = "#282a36";
            cursorColor = "#44475a";
            graphicColor = "#bd93f9";
            showIcons = false;
          };
          # YAML info styles.
          yaml = {
            keyColor = "#ff79c6";
            colonColor = "#bd93f9";
            valueColor = "#f8f8f2";
          };
          # Logs styles.
          logs = {
            fgColor = "#f8f8f2";
            bgColor = "#282a36";
            indicator = {
              fgColor = "#f8f8f2";
              bgColor = "#bd93f9";
            };
          };
        };
      };
    };
  };

  xdg = {
    desktopEntries = {
      k9s = {
        name = "k9s";
        genericName = "k8s CLI";
        comment = "Monitor and control k8s clusters";
        exec = "k9s";
        icon = "kubernetes";
        terminal = true;
        categories = [
          "Network"
          "ConsoleOnly"
        ];
        type = "Application";
      };
    };
  };

}
