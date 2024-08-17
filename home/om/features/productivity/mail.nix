{ lib, config, ...}: let
  mbsync = "${config.programs.mbsync.package}/bin/mbsync";
  pass = "${config.programs.password-store.package}/bin/pass";
  # fastmailAddress = builtins.readFile "${config.sops.secrets.email_fastmail_address.path}";
  fastmailAddress = "${pass} email/fastmail_address";

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
          address = fastmailAddress;

          smtp.host = "smtp.fastmail.com";
          userName = address;

          aliases = [
            fastmailAddress
          ];
          passwordCommand = "${pass} email/${address}";

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
      # gmail =
      #   rec {
      #     primary = false;
      #     msmtp.enable = true;
      #     address = gmailAddress;

      #     smtp.host = "smtp.gmail.com";
      #     userName = gmailAddress;

      #     aliases = [
      #       gmail
      #     ];
      #     passwordCommand = "${pass} email/${address}";

      #     imap.host = "imap.gmail.com";
      #     mbsync = {
      #       enable = true;
      #       create = "maildir";
      #       expunge = "both";
      #     };
      #     folders = {
      #       inbox = "Inbox";
      #       drafts = "Drafts";
      #       sent = "Sent";
      #       trash = "Trash";
      #     };
      #     neomutt = {
      #       enable = true;
      #       extraMailboxes = [
      #         "Archive"
      #         "Drafts"
      #         "Spam"
      #         "Sent"
      #         "Trash"
      #       ];
      #     };
      #   } // common;
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
