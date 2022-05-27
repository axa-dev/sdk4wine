# shellcheck shell=sh disable=SC2154

export winExe

checkInstallation() {
  if [ ! -f "$winExe" ]; then
    printf "\
      \n The binary requested was not found!
      \n It should have been found as \"%s\"\n
      \n Maybe you need to install it with:\n
      \n   %s/luaw %s install\n
      \n" "$winExe" "$selfDir" "$luaVersion"
      exit 1
  fi
  return 0
}


case "$lwcmd" in
  lua)
    winExe="$wincDir$luaDir/bin/lua.exe"
    checkInstallation && wine "$winExe" "$@" ;;

  luac)
    winExe="$wincDir$luaDir/bin/luac.exe"
    checkInstallation && wine "$winExe" "$@" ;;

  #luarocks)
  #  winExe="$wincDir$luarocksDir/luarocks.exe"
  #  checkInstallation && wine "$winExe" --lua-dir="C:\\lua\\${luaVersion}" --lua-version="$luaVersion" "$@";;

  cmd)
    wine cmd;;
esac




