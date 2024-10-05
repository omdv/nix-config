{ lib, config, pkgs, ...}: let
  mbsync = "${config.programs.mbsync.package}/bin/mbsync";
  fastmail_password = "${pkgs.coreutils-full}/bin/cat ${config.sops.secrets.fastmail_password.path}";
  gmail_password = "${pkgs.coreutils-full}/bin/cat ${config.sops.secrets.gmail_password.path}";

  common = rec {
    realName = "Oleg Medvedev";
    signature = {
      showSignature = "append";
      text = ''
        ${realName}
        https://hut.sh
      '';
    };
  };
in {
  accounts.email = {
    maildirBasePath = "Mail";
    accounts = {
      personal =
        rec {
          primary = true;
          msmtp.enable = true;
          address = "omdv@fastmail.com";

          smtp.host = "smtp.fastmail.com";
          userName = address;

          aliases = [
            "omdv@fastmail.com"
          ];
          passwordCommand = fastmail_password;

          imap.host = "imap.fastmail.com";
          mbsync = {
            enable = true;
            create = "maildir";
            expunge = "both";
          };
          folders = {
            inbox = "Inbox";
            drafts = "Drafts";
            sent = "Sent";
            trash = "Trash";
          };
          neomutt = {
            enable = true;
            extraMailboxes = [
              "Archive"
              "Drafts"
              "Spam"
              "Sent"
              "Trash"
            ];
          };
        } // common;
      gmail =
        rec {
          primary = false;
          msmtp.enable = true;
          address = "ole.bjorne@gmail.com";

          smtp.host = "smtp.gmail.com";
          userName = address;

          aliases = [
            "ole.bjorne@gmail.com"
          ];
          passwordCommand = gmail_password;

          imap.host = "imap.gmail.com";
          mbsync = {
            enable = true;
            create = "maildir";
            expunge = "both";
            patterns = [ "*" "[Gmail]*" ];
          };
          folders = {
            inbox = "Inbox";
            drafts = "[Gmail]/Drafts";
            sent   = "[Gmail]/Sent Mail";
            trash  = "[Gmail]/Trash";
          };
          neomutt = {
            enable = true;
            extraMailboxes = [
              "Inbox"
              "[Gmail]/Drafts"
              "[Gmail]/Sent Mail"
              "[Gmail]/Spam"
              "[Gmail]/Starred"
              "[Gmail]/Important"
              "[Gmail]/Trash"
            ];
          };
        } // common;
    };
  };

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;

  systemd.user.services.mbsync = {
    Unit = {
      Description = "mbsync synchronization";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${mbsync} -a";
    };
  };
  systemd.user.timers.mbsync = {
    Unit = {
      Description = "Automatic mbsync synchronization";
    };
    Timer = {
      OnBootSec = "30";
      OnUnitActiveSec = "5m";
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };

  # Run 'createMaildir' after 'linkGeneration'
  home.activation = let
    mbsyncAccounts = lib.filter (a: a.mbsync.enable) (lib.attrValues config.accounts.email.accounts);
  in lib.mkIf (mbsyncAccounts != [ ]) {
    createMaildir = lib.mkForce (lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run mkdir -m700 -p $VERBOSE_ARG ${
        lib.concatMapStringsSep " " (a: a.maildir.absPath) mbsyncAccounts
      }
    '');
  };
}
