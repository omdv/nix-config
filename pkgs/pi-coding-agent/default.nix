{ writeShellScriptBin, nodejs_22 }:
writeShellScriptBin "pi" ''
  export PATH="${nodejs_22}/bin:$PATH"
  exec npx @mariozechner/pi-coding-agent "$@"
''
