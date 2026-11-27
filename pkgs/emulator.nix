{
  pkgs,
  nixosConfig,
  nixpkgsPath,
}: let
  system = nixosConfig.system.build.toplevel;
  runtimeVersion = "0.2.0-261124-c08e977";
  runtimeSource = pkgs.fetchurl {
    url = "https://registry.npmjs.org/unkernel/-/unkernel-${runtimeVersion}.tgz";
    hash = "sha256-BLDBUCv5sVpjxKWarqfJ4KMcQkHnnmgjWzZ/f3TP2IM=";
  };
  runtime =
    pkgs.runCommand "unkernel-${runtimeVersion}" {
      nativeBuildInputs = [pkgs.gnutar pkgs.gzip];
    } ''
      mkdir -p "$out"
      tar -xzf ${runtimeSource} --strip-components=1 -C "$out"
    '';

  image = pkgs.callPackage (nixpkgsPath + "/nixos/lib/make-ext4-fs.nix") {
    storePaths = [system nixosConfig.system.build.emulatorInit];
    volumeLabel = "kwroot";
    populateImageCommands = ''
      mkdir -p ./files/{bin,sbin,etc,root,home/om,dev,proc,sys,run,tmp,usr/lib}
      ln -s ${pkgs.bash}/bin/sh ./files/bin/sh
      ln -s ${nixosConfig.system.build.emulatorInit} ./files/sbin/init
      printf 'nixos\n' > ./files/usr/lib/kw-distro
      printf '%s\n' '${builtins.baseNameOf system}' > ./files/usr/lib/kw-image
    '';
  };

  terminalSource = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@xterm/xterm/-/xterm-5.5.0.tgz";
    hash = "sha512-hqJHYaQb5OptNunnyAnkHyM8aCjZ1MEIDTQu1iIbbTD/xops91NB5yq1ZK/dC2JDbVWtF23zUtl9JE2NqwT87A==";
  };
  fitSource = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@xterm/addon-fit/-/addon-fit-0.10.0.tgz";
    hash = "sha512-UFYkDm4HUahf2lnEyHvio51TNGiLK66mqP2JoATy7hRZeXaGMRDr00JiSF7m63vR5WKATF605yEggJKsw0JpMQ==";
  };

  manifestScript = pkgs.writeText "emulator-manifest.mjs" ''
    import { createHash } from "node:crypto";
    import { createReadStream } from "node:fs";
    import { readdir, stat, writeFile } from "node:fs/promises";
    const root = process.argv[2];
    const types = {".html":"text/html; charset=utf-8", ".mjs":"text/javascript",
      ".js":"text/javascript", ".css":"text/css", ".wasm":"application/wasm",
      ".json":"application/json", ".ext4":"application/octet-stream"};
    const files = {};
    async function walk(directory = "") {
      for (const name of (await readdir(root + "/" + directory)).sort()) {
        const relative = directory + name, path = root + "/" + relative;
        const info = await stat(path);
        if (info.isDirectory()) { await walk(relative + "/"); continue; }
        const hash = createHash("sha256");
        for await (const chunk of createReadStream(path)) hash.update(chunk);
        files[relative] = {bytes:info.size, sha256:hash.digest("hex"),
          contentType:types[name.slice(name.lastIndexOf("."))] || "text/plain"};
      }
    }
    await walk();
    await writeFile(root + "/manifest.json", JSON.stringify({
      schemaVersion:1, runtimeVersion:"${runtimeVersion}", system:"aarch64-linux",
      configuration:"${baseNameOf system}",
      image:{path:"image.ext4", ...files["image.ext4"]}, files
    }, null, 2) + "\n");
  '';

  site =
    pkgs.runCommand "emulator" {
      nativeBuildInputs = [pkgs.gnutar pkgs.gzip pkgs.nodejs_24];
    } ''
      mkdir -p "$out"/{runtime,terminal,fit}
      cp ${../hosts/emulator/index.html} "$out/index.html"
      cp -r ${runtime}/dist/. "$out/runtime/"
      cp ${runtime}/LICENSE ${runtime}/LICENSE-MIT ${runtime}/THIRD-PARTY.md "$out/runtime/"
      tar -xzf ${terminalSource} --strip-components=1 -C "$out/terminal"
      tar -xzf ${fitSource} --strip-components=1 -C "$out/fit"
      ln -s ${image} "$out/image.ext4"
      node ${manifestScript} "$out"
    '';

  serveScript = pkgs.writeText "emulator-preview.mjs" ''
    import { createServer } from "node:http";
    import { createReadStream } from "node:fs";
    import { stat, readFile } from "node:fs/promises";
    import { resolve } from "node:path";
    const root = process.argv[2];
    const manifest = JSON.parse(await readFile(root + "/manifest.json", "utf8"));
    createServer(async (request, response) => {
      try {
        if (!["GET", "HEAD"].includes(request.method)) {
          response.writeHead(405, {Allow:"GET, HEAD"}).end(); return;
        }
        const relative = decodeURIComponent(new URL(request.url, "http://localhost").pathname).replace(/^\/+/, "") || "index.html";
        const path = resolve(root, relative);
        if (!path.startsWith(root + "/")) { response.writeHead(403).end(); return; }
        const info = await stat(path);
        if (!info.isFile()) { response.writeHead(404).end(); return; }
        const headers = {"Content-Type":relative === "manifest.json" ? "application/json" :
          manifest.files[relative]?.contentType || "application/octet-stream",
          "Accept-Ranges":"bytes", "Cache-Control":"no-cache"};
        let start = 0, end = info.size - 1, status = 200;
        if (request.headers.range) {
          const match = /^bytes=(\d+)-(\d*)$/.exec(request.headers.range);
          if (match) { start = Number(match[1]); end = match[2] ? Math.min(Number(match[2]), end) : end; }
          if (!match || !Number.isSafeInteger(start) || start > end || start >= info.size) {
            response.writeHead(416, {"Content-Range":"bytes */" + info.size}).end(); return;
          }
          status = 206; headers["Content-Range"] = "bytes " + start + "-" + end + "/" + info.size;
        }
        headers["Content-Length"] = Math.max(0, end - start + 1);
        response.writeHead(status, headers);
        if (request.method === "HEAD" || !info.size) response.end();
        else createReadStream(path, {start, end}).on("error", () => response.destroy()).pipe(response);
      } catch (error) {
        if (!response.headersSent) response.writeHead(error.code === "ENOENT" ? 404 : 500);
        response.end();
      }
    }).listen(Number(process.env.PORT || 8080), "127.0.0.1", function () {
      console.log("Emulator site: http://127.0.0.1:" + this.address().port + "/");
    });
  '';

  serve = pkgs.writeShellApplication {
    name = "emulator";
    runtimeInputs = [pkgs.nodejs_24];
    text = ''exec node ${serveScript} ${site} "$@"'';
  };
in {
  inherit site serve;
}
