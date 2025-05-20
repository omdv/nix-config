{
  config,
  pkgs,
  lib,
  ...
}: {
  xdg = {
    desktopEntries = {
      neomutt = {
        name = "Neomutt";
        genericName = "Email Client";
        comment = "Read and send emails";
        exec = "neomutt %U";
        icon = "mutt";
        terminal = true;
        categories = [
          "Network"
          "Email"
          "ConsoleOnly"
        ];
        type = "Application";
        mimeType = ["x-scheme-handler/mailto"];
      };
    };
    mimeApps.defaultApplications = {
      "x-scheme-handler/mailto" = "neomutt.desktop";
    };
  };

  home.packages = with pkgs; [
    w3m
    feh
  ];

  programs.neomutt = {
    enable = true;
    vimKeys = false;
    checkStatsInterval = 60;
    sidebar = {
      enable = true;
      width = 30;
    };
    settings = {
      mark_old = "no";
      text_flowed = "yes";
      reverse_name = "yes";
      query_command = ''"khard email --parsable '%s'"'';
    };
    binds = [
      {
        action = "sidebar-toggle-visible";
        key = "\\\\";
        map = [
          "index"
          "pager"
        ];
      }
      {
        action = "group-reply";
        key = "L";
        map = [
          "index"
          "pager"
        ];
      }
      {
        action = "toggle-new";
        key = "B";
        map = ["index"];
      }
      {
        action = "display-message";
        key = "<Return>";
        map = [
          "index"
        ];
      }
    ];
    macros = [
      {
        action = "<sidebar-next><sidebar-open>";
        key = "J";
        map = [
          "index"
          "pager"
        ];
      }
      {
        action = "<sidebar-prev><sidebar-open>";
        key = "K";
        map = [
          "index"
          "pager"
        ];
      }
      {
        action = "<save-message>+Archive<enter>";
        key = "A";
        map = [
          "index"
          "pager"
        ];
      }
      {
        key = "H";
        map = ["pager"];
        action = "<pipe-message>${pkgs.w3m}/bin/w3m -I UTF-8 -T text/html -dump<enter><exit>";
      }
    ];
    extraConfig = let
      # Collect all addresses and aliases
      addresses = lib.flatten (
        lib.mapAttrsToList (n: v: [v.address] ++ v.aliases) config.accounts.email.accounts
      );
    in
      ''
        alternates "${lib.concatStringsSep "|" addresses}"
      ''
      + ''
        set mailcap_path = "${config.xdg.configHome}/neomutt/mailcap"

        set implicit_autoview
        alternative_order text/plain text/enriched text/html multipart/related multipart/alternative
        set allow_ansi

        # From: https://github.com/dracula/mutt/blob/master/dracula.muttrc
        # general ------------ foreground ---- background -----------------------------
        color error		color231	color212
        color indicator		color231	color241
        color markers		color210	default
        color message		default		default
        color normal		default		default
        color prompt		default	        default
        color search		color84		default
        color status 		color141	color236
        color tilde		color231	default
        color tree		color141	default

        # message index ------ foreground ---- background -----------------------------
        color index		color210	default 	~D # deleted messages
        color index		color84		default 	~F # flagged messages
        color index		color117	default 	~N # new messages
        color index		color212	default 	~Q # messages which have been replied to
        color index		color215	default 	~T # tagged messages
        color index		color141	default		~v # messages part of a collapsed thread

        # message headers ---- foreground ---- background -----------------------------
        color hdrdefault	color117	default
        color header		color231	default		^Subject:.*

        # message body ------- foreground ---- background -----------------------------
        color attachment	color228	default
        color body		color231	default		[\-\.+_a-zA-Z0-9]+@[\-\.a-zA-Z0-9]+               # email addresses
        color body		color228	default		(https?|ftp)://[\-\.,/%~_:?&=\#a-zA-Z0-9]+        # URLs
        color body		color231	default		(^|[[:space:]])\\*[^[:space:]]+\\*([[:space:]]|$) # *bold* text
        color body		color231	default		(^|[[:space:]])_[^[:space:]]+_([[:space:]]|$)     # _underlined_ text
        color body		color231	default		(^|[[:space:]])/[^[:space:]]+/([[:space:]]|$)     # /italic/ text
        color quoted		color61		default
        color quoted1		color117	default
        color quoted2		color84		default
        color quoted3		color215	default
        color quoted4		color212	default
        color signature		color212	default

      '';
  };

  xdg.configFile."neomutt/mailcap".text = ''
    text/html; ${pkgs.w3m}/bin/w3m -I %{charset} -T text/html -dump %s; copiousoutput
    text/html; ${pkgs.w3m}/bin/w3m -I UTF-8 -T text/html -dump %s; copiousoutput
    image/png; ${pkgs.feh}/bin/feh %s; copiousoutput
    image/jpeg; ${pkgs.feh}/bin/feh %s; copiousoutput
    image/gif; ${pkgs.feh}/bin/feh %s; copiousoutput
  '';

}
