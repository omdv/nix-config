{
  writeShellScriptBin,
  nodejs_22,
}:
writeShellScriptBin "dirac" ''
  export PATH="${nodejs_22}/bin:$PATH"
  exec ${nodejs_22}/bin/npx -y dirac-cli@latest "$@"
''
