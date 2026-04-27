{
  lib,
  pkgs,
  config,
  ...
}: let
  repoDir = "${config.home.homeDirectory}/nix-config";

  mkScript = {
    name ? "script",
    deps ? [],
    script ? "",
  }:
    lib.getExe (pkgs.writeShellApplication {
      inherit name;
      text = script;
      runtimeInputs = deps;
    });

  jjAutoCommit = mkScript {
    name = "jj-auto-commit";
    deps = [
      pkgs.jujutsu
      pkgs.unstable.aichat
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.gnused
    ];
    script = ''
      set -euo pipefail

      REPO_DIR="${repoDir}"
      DRY_RUN=false
      PUBLISH=false

      usage() {
        cat <<'EOF'
      Usage: jj-auto-commit [--dry-run|-n] [--publish] [--help|-h]

      Generates a commit message with aichat from current jj diff and commits it.

      Options:
        -n, --dry-run   Generate and print message, but do not commit
            --publish   After commit, move bookmark to @- and push
        -h, --help      Show this help
      EOF
      }

      while [[ $# -gt 0 ]]; do
        case "$1" in
          -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
          --publish)
            PUBLISH=true
            shift
            ;;
          -h|--help)
            usage
            exit 0
            ;;
          *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
        esac
      done

      cd "$REPO_DIR"

      CHANGED_PATHS="$(jj diff --name-only 2>/dev/null || true)"
      if [[ -z "''${CHANGED_PATHS//[[:space:]]/}" ]]; then
        echo "No changes detected. Nothing to do."
        exit 0
      fi

      DIFF_SUMMARY="$(jj diff --summary 2>/dev/null || true)"
      DIFF_GIT="$(jj diff --git 2>/dev/null | head -c 12000 || true)"

      PROMPT=$(cat <<EOF
      You are generating a git/jj commit message.

      Rules:
      - Output only commit message text.
      - Use Conventional Commits style.
      - Keep subject line <= 72 characters.
      - Imperative mood, concise, specific.
      - Add a short body only if needed.

      Repository diff summary:
      ''${DIFF_SUMMARY}

      Repository diff (truncated):
      ''${DIFF_GIT}
      EOF
      )

      MSG="$(aichat --no-stream "$PROMPT" 2>/dev/null || true)"
      MSG="$(printf '%s' "$MSG" | sed '/^[[:space:]]*$/d' | sed 's/^```.*$//g' | sed 's/^"//; s/"$//')"

      if [[ -z "''${MSG//[[:space:]]/}" ]]; then
        MSG="chore: automated snapshot"
      fi

      echo "Generated commit message:"
      echo "----------------------------------------"
      echo "$MSG"
      echo "----------------------------------------"

      if [[ "$DRY_RUN" == "true" ]]; then
        echo "Dry-run enabled; skipping commit."
        exit 0
      fi

      jj commit -m "$MSG"
      echo "Committed successfully."

      if [[ "$PUBLISH" == "true" ]]; then
        BOOKMARK=""
        if jj bookmark list | grep -q '^main:'; then
          BOOKMARK="main"
        elif jj bookmark list | grep -q '^master:'; then
          BOOKMARK="master"
        else
          echo "Publish requested, but neither 'main' nor 'master' bookmark exists." >&2
          exit 1
        fi

        echo "Publishing via bookmark: $BOOKMARK"
        jj bookmark move "$BOOKMARK" --to @-
        jj git push --bookmark "$BOOKMARK"
        echo "Published successfully."
      fi
    '';
  };
in {
  systemd.user.services.jj-auto-commit = {
    Unit = {
      Description = "Auto-commit nix-config changes with jj + aichat";
      After = ["network-online.target"];
      Wants = ["network-online.target"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = jjAutoCommit;
    };
  };

  systemd.user.timers.jj-auto-commit = {
    Unit = {
      Description = "Run jj auto-commit every 3 hours";
    };
    Timer = {
      OnBootSec = "10m";
      OnUnitActiveSec = "3h";
      Persistent = true;
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };

  systemd.user.services.jj-auto-publish = {
    Unit = {
      Description = "Publish jj bookmark once a day";
      After = ["network-online.target"];
      Wants = ["network-online.target"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${jjAutoCommit} --publish";
    };
  };

  systemd.user.timers.jj-auto-publish = {
    Unit = {
      Description = "Run jj auto-publish once a day";
    };
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };
}
