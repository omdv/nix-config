{
  writeShellScriptBin,
  nodejs_22,
}:
writeShellScriptBin "openspec" ''
  export PATH="${nodejs_22}/bin:$PATH"
  exec npx @fission-ai/openspec@1.3.1 "$@"
''
