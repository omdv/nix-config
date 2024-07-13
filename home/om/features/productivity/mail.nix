{
  lib,
  config,
  ...
}: let
  mbsync = "${config.programs.mbsync.package}/bin/mbsync";
  pass = "${config.programs.password-store.package}/bin/pass";

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
          msmtp.enable = true;
          address = "omdv@fastmail.com";

          smtp.host = "smtp.fastmail.com";
          userName = address;

          primary = true;
          aliases = [
            "omdv@fastmail.com"
          ];
          passwordCommand = "${pass} ${address}";

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
        }
        // common;
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
