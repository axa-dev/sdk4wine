# shellcheck shell=sh disable=SC2154

case $luaVersion in
    5.1)
        export luarel="lua-5.1.5"
        export luasrc="https://raw.githubusercontent.com/axa-dev/sdk/lua-5.1/$luarel.tar.gz"
        ;;
    5.2)
        export luarel="lua-5.2.4"
        export luasrc="https://www.lua.org/ftp/$luarel.tar.gz"
        ;;
    5.3)
        export luarel="lua-5.3.6"
        export luasrc="https://www.lua.org/ftp/$luarel.tar.gz"
        ;;
    5.4)
        export luarel="lua-5.4.4"
        export luasrc="https://www.lua.org/ftp/$luarel.tar.gz"
        ;;
    *)
        echo "unknown Lua version: $luaVersion"
        exit;;
esac

export luarocksrel="luarocks-3.9.0-windows-32"

#
# PATHS
#
# Converts linux format paths into windows ones

  dir_comp="/TDM-GCC-32/bin"

# This paths are absolute to C: in Wine, i.e.
# they are relatives to the ${wincDir}
buildDir="$luaRoot/build"
downloadDir="$buildDir/downloads"
srcDir="$buildDir/sources"

mkdir -p "$wincDir$downloadDir"
mkdir -p "$wincDir$srcDir"

#
# FUNCTIONS
#
if [ "1" = "$DEBUG" ]; then set -x ; fi


download_lua() {

    luatgz="$wincDir/$downloadDir/$luarel.tgz"
    curl "$luasrc" > "$luatgz" \
        && tar zxvf "$luatgz" -C "$wincDir/$srcDir" \
        && rm -rf "$luatgz" \
        && return 0
    echo "Error downloading Lua sources"
    exit 1
}

install_luarocks() {
  mkdir -p "$wincDir$luarocksDir"
  destzip="$wincDir$downloadDir/$luarocksrel.zip"
  curl -L "https://luarocks.org/releases/$luarocksrel.zip" > "$destzip" \
    && unzip "$destzip" -d "$wincDir$srcDir" \
    && mv -f "$wincDir$srcDir/$luarocksrel"/* "$wincDir$luarocksDir" \
    && return 0
  echo "Error installing Luarocks"
  exit 1
}

compile_lua() {
    if [ ! -d "$wincDir$dir_comp" ] ; then
        echo "No compile binary dir found under $(wpath "$dir_comp")"
        exit 1
    fi

    cd "$wincDir$srcDir/$luarel" || exit 1
    wine mingw32-make PLAT=mingw

    if [ -z $? ]; then
        echo "Instalation failed. Try again running:"
        echo "  $SCRIPTNAME --debug $luaVersion"
        exit 1
    fi
    return 0;
}

install_lua() {
    mkdir -p "$wincDir$luaDir"
    instdir="$wincDir$luaDir"
    srcdir="$wincDir$srcDir/$luarel"
    for i in doc bin include; do mkdir -p "${instdir}/$i"; done

    cp -rf "$srcdir"/doc/*.*       "$instdir/doc/"
    cp -rf "$srcdir"/src/*.exe     "$instdir/bin/"
    cp -rf "$srcdir"/src/*.dll     "$instdir/bin/"
    cp -rf "$srcdir"/src/luaconf.h "$instdir/include/"
    cp -rf "$srcdir"/src/lua.h     "$instdir/include/"
    cp -rf "$srcdir"/src/lualib.h  "$instdir/include/"
    cp -rf "$srcdir"/src/lauxlib.h "$instdir/include/"
}

#
# LOGIC
#

# Install Luarocks
install_luarocks


# If Lua sources are not downloaded..
[ ! -d "$wincDir$srcDir/$luarel" ] && download_lua ;
compile_lua && install_lua;

wine lua -e "print(('\n\n%s: compiled! \n\n'):format(_VERSION))"
