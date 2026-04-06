{
  config,
  pkgs,
  ...
}: let
  mcDataDir = "${config.home.homeDirectory}/.local/share/mc-clj";
  mcProjectDir = "${config.home.homeDirectory}/.config/mc-clj";

  mcCljStart = pkgs.writeShellScriptBin "mc-clj-start" ''
        set -euo pipefail

        MC_DATA_DIR="${mcDataDir}"
        mkdir -p "$MC_DATA_DIR"

        if [ ! -f "$MC_DATA_DIR/eula.txt" ]; then
          printf 'eula=true\n' > "$MC_DATA_DIR/eula.txt"
        fi

        if [ ! -f "$MC_DATA_DIR/rcon-password" ]; then
          od -An -N16 -tx1 /dev/urandom | tr -d ' \n' | cut -c1-24 > "$MC_DATA_DIR/rcon-password"
          chmod 600 "$MC_DATA_DIR/rcon-password"
          echo "Generated RCON password at: $MC_DATA_DIR/rcon-password"
        fi

        cat > "$MC_DATA_DIR/server.properties" <<EOF
    motd=Clojure Craft School
    server-port=25565
    enable-rcon=true
    rcon.port=25575
    rcon.password=$(cat "$MC_DATA_DIR/rcon-password")
    gamemode=creative
    difficulty=easy
    enable-command-block=true
    spawn-protection=0
    EOF

        echo ""
        echo "Minecraft server dir: $MC_DATA_DIR"
        echo "Start Prism Launcher, connect to: localhost:25565"
        echo "Open another terminal and run: mc-clj-repl"
        echo ""

        cd "$MC_DATA_DIR"
        exec ${pkgs.minecraft-server}/bin/minecraft-server -Xms2G -Xmx4G
  '';

  mcCljRepl = pkgs.writeShellScriptBin "mc-clj-repl" ''
    set -euo pipefail

    cd "${mcProjectDir}"

    echo ""
    echo "REPL tips:"
    echo "  (require '[mc-clj.core :as mc])"
    echo "  (mc/say! \"Hello from Clojure!\")"
    echo "  (mc/house! 0 64 0 7 5 7 \"minecraft:oak_planks\")"
    echo ""

    exec ${pkgs.clojure}/bin/clj
  '';
in {
  home.packages = with pkgs; [
    clojure
    jdk21
    mcrcon
    minecraft-server
    prismlauncher
    mcCljStart
    mcCljRepl
  ];

  home.file.".config/mc-clj/deps.edn".text = ''
    {:paths ["src"]}
  '';

  home.file.".config/mc-clj/src/mc_clj/core.clj".text = ''
    (ns mc-clj.core
      (:require [clojure.java.shell :as sh]
                [clojure.string :as str]))

    (def ^:private rcon-bin "${pkgs.mcrcon}/bin/mcrcon")
    (def ^:private rcon-host "127.0.0.1")
    (def ^:private rcon-port "25575")
    (def ^:private rcon-password-file "${mcDataDir}/rcon-password")

    (defn- rcon-password []
      (-> (slurp rcon-password-file) str/trim))

    (defn cmd!
      "Send a raw server command through RCON."
      [command]
      (let [{:keys [exit out err]}
            (sh/sh rcon-bin
                   "-H" rcon-host
                   "-P" rcon-port
                   "-p" (rcon-password)
                   command)]
        (when-not (zero? exit)
          (throw (ex-info "RCON command failed" {:command command :err err :exit exit})))
        (str/trim out)))

    (defn say! [message]
      (cmd! (str "say " message)))

    (defn set-block!
      [x y z block]
      (cmd! (format "setblock %d %d %d %s" x y z block)))

    (defn fill!
      [x1 y1 z1 x2 y2 z2 block]
      (cmd! (format "fill %d %d %d %d %d %d %s" x1 y1 z1 x2 y2 z2 block)))

    (defmacro repeat-build
      "Repeat body n times, useful for macro teaching."
      [n & body]
      `(dotimes [i# ~n]
         ~@body))

    (defn wall!
      [x y z width height block]
      (doseq [dx (range width)
              dy (range height)]
        (set-block! (+ x dx) (+ y dy) z block)))

    (defn box!
      "Build a simple hollow box house."
      [x y z width height depth block]
      ;; floor
      (fill! x y z (+ x (dec width)) y (+ z (dec depth)) block)
      ;; roof
      (fill! x (+ y (dec height)) z
             (+ x (dec width)) (+ y (dec height)) (+ z (dec depth))
             block)
      ;; walls
      (fill! x (inc y) z x (+ y (- height 2)) (+ z (dec depth)) block)
      (fill! (+ x (dec width)) (inc y) z (+ x (dec width)) (+ y (- height 2)) (+ z (dec depth)) block)
      (fill! x (inc y) z (+ x (dec width)) (+ y (- height 2)) z block)
      (fill! x (inc y) (+ z (dec depth)) (+ x (dec width)) (+ y (- height 2)) (+ z (dec depth)) block)
      :ok)
  '';
}
