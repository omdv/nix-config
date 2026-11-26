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
      passthru.smoke = smoke;
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
  smokeScript = pkgs.writeText "emulator-smoke.mjs" ''
    import assert from "node:assert/strict";
    import { spawn } from "node:child_process";
    import { mkdir, mkdtemp, writeFile, rm } from "node:fs/promises";
    import { tmpdir } from "node:os";
    import { join } from "node:path";
    import { setTimeout as delay } from "node:timers/promises";
    const url = new URL(process.argv[2] || "http://127.0.0.1:8080/").href;
    const output = process.env.EMULATOR_SMOKE_OUTPUT || await mkdtemp(join(tmpdir(), "emulator-smoke-"));
    await mkdir(output, {recursive:true});
    const profile = await mkdtemp(join(tmpdir(), "browser-profile-"));
    const browser = spawn(process.env.BROWSER || "${pkgs.chromium}/bin/chromium", [
      "--headless", "--disable-gpu", "--disable-background-networking", "--no-first-run",
      "--remote-debugging-address=127.0.0.1", "--remote-debugging-port=0",
      "--user-data-dir=" + profile, ...JSON.parse(process.env.BROWSER_ARGS || "[]"), "about:blank"
    ], {stdio:["ignore", "ignore", "pipe"]});
    let browserLog = "", socket, session, serial = 0;
    const pending = new Map(), events = [];
    const browserExited = new Promise(resolve => browser.once("exit", resolve));
    browser.stderr.on("data", bytes => { browserLog += bytes.toString(); });
    const endpoint = new Promise((resolve, reject) => {
      const timer = setTimeout(() => reject(new Error("Chromium did not expose DevTools")), 30000);
      browser.once("error", error => { clearTimeout(timer); reject(error); });
      browser.once("exit", code => { clearTimeout(timer); reject(new Error("Chromium exited: " + code)); });
      browser.stderr.on("data", () => {
        const match = /DevTools listening on (ws:\/\/127\.0\.0\.1:\d+\/[^\s]+)/.exec(browserLog);
        if (match) { clearTimeout(timer); resolve(match[1]); }
      });
    });
    function call(method, params = {}, sessionId = session, timeout = 30000) {
      return new Promise((resolve, reject) => {
        const id = ++serial;
        const timer = setTimeout(() => { pending.delete(id); reject(new Error("CDP timeout: " + method)); }, timeout);
        pending.set(id, {resolve, reject, timer});
        socket.send(JSON.stringify({id, method, params, ...(sessionId ? {sessionId} : {})}));
      });
    }
    async function evaluate(expression, timeout = 30000) {
      const result = await call("Runtime.evaluate", {expression, awaitPromise:true, returnByValue:true}, session, timeout);
      if (result.exceptionDetails) throw new Error(result.exceptionDetails.exception?.description || result.exceptionDetails.text);
      return result.result.value;
    }
    async function waitFor(expression, timeout = 180000) {
      const deadline = Date.now() + timeout;
      while (Date.now() < deadline) {
        try { if (await evaluate(expression)) return; }
        catch (error) {
          if (!/Execution context was destroyed|Cannot find context|Inspected target navigated/.test(error.message)) throw error;
        }
        await delay(200);
      }
      throw new Error("Timed out waiting for " + expression);
    }
    async function screenshot(name) {
      const {cssContentSize} = await call("Page.getLayoutMetrics");
      const {data} = await call("Page.captureScreenshot", {format:"png", captureBeyondViewport:true,
        clip:{x:0, y:0, width:cssContentSize.width, height:cssContentSize.height, scale:1}});
      await writeFile(join(output, name + ".png"), Buffer.from(data, "base64"));
    }
    async function assertTerminalFits() {
      const geometry = await evaluate(`(async () => {
        await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
        const frame = document.getElementById('terminal-frame');
        const rect = frame.getBoundingClientRect(), style = getComputedStyle(frame);
        return {
          content: {
            left:rect.left + parseFloat(style.borderLeftWidth) + parseFloat(style.paddingLeft),
            right:rect.right - parseFloat(style.borderRightWidth) - parseFloat(style.paddingRight),
            top:rect.top + parseFloat(style.borderTopWidth) + parseFloat(style.paddingTop),
            bottom:rect.bottom - parseFloat(style.borderBottomWidth) - parseFloat(style.paddingBottom)
          },
          screen:document.querySelector('#terminal .xterm-screen').getBoundingClientRect().toJSON(),
          viewport:{width:innerWidth, height:innerHeight}
        };
      })()`);
      const {content, screen} = geometry;
      assert.ok(screen.left >= content.left - 1 && screen.right <= content.right + 1 &&
        screen.top >= content.top - 1 && screen.bottom <= content.bottom + 1,
        "Terminal exceeds its frame content area: " + JSON.stringify(geometry));
      return geometry;
    }
    async function guest(command) {
      const result = await evaluate("emulator.vm.exec('/run/current-system/sw/bin/bash', ['-lc', " +
        JSON.stringify(command) + "], {user:'om', timeout:30000, signal:AbortSignal.timeout(60000)})", 65000);
      assert.equal(result.exitCode, 0, result.stderr + "\n" + result.stdout);
      return result.stdout.trim();
    }
    async function key(key, code, windowsVirtualKeyCode, text, modifiers = 0) {
      await call("Input.dispatchKeyEvent", {type:text ? "keyDown" : "rawKeyDown", key, code, windowsVirtualKeyCode, modifiers, ...(text ? {text} : {})});
      await call("Input.dispatchKeyEvent", {type:"keyUp", key, code, windowsVirtualKeyCode, modifiers});
    }
    async function type(text) { await call("Input.insertText", {text}); }
    async function enter() { await key("Enter", "Enter", 13, "\r"); }
    async function terminalContains(text) {
      await waitFor("Array.from({length:emulator.terminal.buffer.active.length},(_,i)=>emulator.terminal.buffer.active.getLine(i)?.translateToString(true)).join('\\n').includes(" + JSON.stringify(text) + ")", 30000);
    }
    async function ready(button) {
      const start = performance.now();
      await evaluate("document.getElementById(" + JSON.stringify(button) + ").click()");
      await waitFor("['ready','error'].includes(emulator.state)");
      assert.equal(await evaluate("emulator.state"), "ready", await evaluate("document.getElementById('status').textContent"));
      assert.equal(await evaluate("document.getElementById('status').checkVisibility()"), false);
      return (performance.now() - start) / 1000;
    }
    try {
      socket = new WebSocket(await endpoint);
      await new Promise((resolve, reject) => {
        socket.addEventListener("open", resolve, {once:true});
        socket.addEventListener("error", reject, {once:true});
      });
      socket.addEventListener("message", async event => {
        const message = JSON.parse(event.data);
        if (message.id) {
          const request = pending.get(message.id);
          if (!request) return;
          pending.delete(message.id); clearTimeout(request.timer);
          if (message.error) request.reject(new Error(message.error.message));
          else request.resolve(message.result);
        } else {
          if (message.method === "Runtime.exceptionThrown") events.push(message);
          if (message.method === "Fetch.requestPaused") {
            try { await call("Fetch.failRequest", {requestId:message.params.requestId, errorReason:"Failed"}, message.sessionId); }
            catch (error) { events.push({interceptionError:error.message}); }
          }
        }
      });
      socket.addEventListener("close", () => {
        for (const request of pending.values()) { clearTimeout(request.timer); request.reject(new Error("Chromium disconnected")); }
        pending.clear();
      });
      const target = await call("Target.createTarget", {url:"about:blank"}, null);
      session = (await call("Target.attachToTarget", {targetId:target.targetId, flatten:true}, null)).sessionId;
      await call("Page.enable"); await call("Runtime.enable");
      await call("Emulation.setDeviceMetricsOverride", {width:1100, height:800, deviceScaleFactor:1, mobile:false});
      await call("Page.navigate", {url});
      await waitFor("typeof emulator !== 'undefined'");
      const coldReadySeconds = await ready("boot");
      const identity = await guest([
        "set -eu", 'test "$(id -un)" = om', 'test "$(cat /proc/1/comm)" = systemd',
        ". /etc/os-release", 'test "$ID" = nixos', "systemctl is-system-running --wait",
        "systemctl is-active register-nix-paths home-manager-om emulator-terminal",
        'test "$(git config commit.gpgSign)" = false', 'test -f "$HOME/.config/starship.toml"',
        "fish -lc 'printf FISH_READY'", "jq -n '{ready:true}'"
      ].join("\n"));
      const consoleSample = "\x1b[1;32mBOOT_LOG_VISIBLE\x1b[0m\n\x1b]3008;BOOT_LOG_HIDDEN\x1b\\BOOT_LOG_END\n";
      const consoleCommand = "printf '%s' '" + consoleSample + "' > /dev/console";
      const consoleWrite = await evaluate("emulator.vm.exec('/run/current-system/sw/bin/bash', ['-lc', " +
        JSON.stringify(consoleCommand) + "], {user:'root', timeout:30000})", 65000);
      assert.equal(consoleWrite.exitCode, 0, consoleWrite.stderr);
      await waitFor("['BOOT_LOG_VISIBLE','BOOT_LOG_END'].every(text => document.getElementById('boot-log').textContent.includes(text))", 30000);
      const bootLog = await evaluate("document.getElementById('boot-log').textContent");
      assert.doesNotMatch(bootLog, /BOOT_LOG_HIDDEN|[\x1b\x90\x98\x9b-\x9f]/);
      await evaluate("document.getElementById('diagnostics').open = true; document.getElementById('boot-log').scrollTop = document.getElementById('boot-log').scrollHeight");
      await screenshot("diagnostics");
      await writeFile(join(output, "diagnostics.log"), bootLog);
      await evaluate("document.getElementById('diagnostics').open = false");
      const baseline = await guest("sha256sum ~/.config/starship.toml");
      const initialBounds = await assertTerminalFits();
      await screenshot("ready");
      await evaluate("emulator.terminal.focus()");
      await type("nvim ~/emulator-smoke.txt"); await enter();
      await waitFor("emulator.terminal.buffer.active.type === 'alternate'", 30000);
      await terminalContains("emulator-smoke.txt");
      await type("iEmulator Nixvim smoke");
      await terminalContains("Emulator Nixvim smoke");
      await terminalContains("INSERT");
      await screenshot("editor");
      await key("Escape", "Escape", 27);
      await terminalContains("NORMAL");
      await type(":wq"); await enter();
      await waitFor("emulator.terminal.buffer.active.type === 'normal'", 30000);
      assert.equal(await guest("cat ~/emulator-smoke.txt"), "Emulator Nixvim smoke");
      await call("Emulation.setDeviceMetricsOverride", {width:560, height:640, deviceScaleFactor:1, mobile:false});
      await evaluate("emulator.terminal.focus()");
      await key("c", "KeyC", 67, undefined, 2);
      await type("stty size > ~/emulator-terminal-size; printf '\\nRESIZE_READY\\n'"); await enter();
      await waitFor("Array.from({length:emulator.terminal.buffer.active.length},(_,i)=>emulator.terminal.buffer.active.getLine(i)?.translateToString(true).trim()).includes('RESIZE_READY')", 30000);
      assert.equal(await guest("cat ~/emulator-terminal-size"),
        await evaluate("emulator.terminal.rows + ' ' + emulator.terminal.cols"));
      const resizedBounds = await assertTerminalFits();
      await screenshot("resized");
      await guest("rm ~/.config/starship.toml; printf 'add_newline = false\\n' > ~/.config/starship.toml");
      const warmReadySeconds = await ready("restart");
      assert.equal(await guest("test ! -e ~/emulator-smoke.txt; test ! -e ~/emulator-terminal-size; sha256sum ~/.config/starship.toml"), baseline);
      await screenshot("reset");
      await writeFile(join(output, "boot.log"), await evaluate("document.getElementById('boot-log')?.textContent || document.body.innerText"));
      // Fail the real image request: the page must not report readiness or fall back.
      await call("Network.enable"); await call("Network.setCacheDisabled", {cacheDisabled:true});
      await call("Fetch.enable", {patterns:[{urlPattern:"*image.ext4*", requestStage:"Request"}]});
      await evaluate("document.getElementById('restart').click()");
      await waitFor("emulator.state === 'error'");
      assert.notEqual(await evaluate("emulator.state"), "ready");
      assert.equal(await evaluate("document.getElementById('status').checkVisibility()"), true);
      await screenshot("bad-image");
      const report = {url, coldReadySeconds, warmReadySeconds, identity, baseline, initialBounds, resizedBounds, reset:true, badImageRejected:true};
      await writeFile(join(output, "result.json"), JSON.stringify(report, null, 2) + "\n");
      console.log(JSON.stringify(report, null, 2));
      console.log("Emulator evidence: " + output);
    } catch (error) {
      if (session && socket?.readyState === WebSocket.OPEN) {
        try {
          await screenshot("failure");
          await writeFile(join(output, "failure-page.txt"), await evaluate("document.body.innerText"));
        } catch {}
      }
      throw error;
    } finally {
      await writeFile(join(output, "chromium.log"), browserLog);
      await writeFile(join(output, "browser-events.json"), JSON.stringify(events, null, 2));
      socket?.close();
      browser.kill("SIGTERM");
      await Promise.race([browserExited, delay(3000).then(() => browser.kill("SIGKILL"))]);
      await rm(profile, {recursive:true, force:true});
    }
  '';

  smoke = pkgs.writeShellApplication {
    name = "emulator-smoke";
    runtimeInputs = [pkgs.nodejs_24];
    text = ''exec node ${smokeScript} "$@"'';
  };
in {
  inherit site serve;
}
