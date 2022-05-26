#!/bin/bash
export SCRIPTNAME="$0"

if [ "$1" == "--debug" ]; then
    export DEBUG=1
    shift
fi

export LUAVER="$1"
shift

case $LUAVER in
    5.1)
        export luarel="lua-5.1.5"
        export luasrc="https://raw.githubusercontent.com/axa-dev/sdk/lua-5.1/${luarel}.tar.gz"
        ;;
    5.2)
        export luarel="lua-5.2.4"
        export luasrc="https://www.lua.org/ftp/${luarel}.tar.gz"
        ;;
    5.3)
        export luarel="lua-5.3.6"
        export luasrc="https://www.lua.org/ftp/${luarel}.tar.gz"
        ;;
    5.4)
        export luarel="lua-5.4.4"
        export luasrc="https://www.lua.org/ftp/${luarel}.tar.gz"
        ;;
    *)
        echo "unknown Lua version: $LUAVER"
        exit;;
esac

winec="$HOME/.wine/drive_c"

#
# PATHS
#
    # Converts linux format paths into windows ones
    wdir() { echo "C:$@" | sed 's/\//\\\\/g'; }

    winec="${HOME}/.wine/drive_c"
    dir_comp="/TDM-GCC-64/bin"

    # This paths are absolute to C: in Wine, i.e.
    # they are relatives to the ${winec}
    dir_env="/lua"
    dir_build="${dir_env}/build"
    dir_downloads="${dir_build}/downloads"
    dir_src="${dir_build}/sources"
    dir_lua="${dir_env}/${LUAVER}"


#
# FUNCTIONS
#
if [ "1" == "$DEBUG" ]; then set -x ; fi


download_lua() {
    mkdir -p "${winec}${dir_downloads}"
    mkdir -p "${winec}${dir_src}"

    luatgz="${winec}/${dir_downloads}/${luarel}.tgz"
    curl "${luasrc}" > "${luatgz}" \
        && tar zxvf "${luatgz}" -C "${winec}/${dir_src}" \
        && rm -rf "${luatgz}" \
        && return 0
    echo "Error downloading Lua sources"
    exit 1
}

compile_lua() {
    if [ ! -d "${winec}${dir_comp}" ] ; then
        echo "No compile binary dir found under $(wdir "${dir_comp}")"
        exit 1
    fi


    export WINEPATH="${wdir_comp}"

    cd "${winec}${dir_src}/${luarel}"
    wine mingw32-make PLAT=mingw

    if [ -z $? ]; then
        echo "Instalation failed. Try again running:"
        echo "  $SCRIPTNAME --debug $LUAVER"
        exit 1
    fi
    return 0;
}

install_lua() {
    mkdir -p "${winec}${dir_lua}"
    instdir="${winec}${dir_lua}"
    srcdir="${winec}${dir_src}/${luarel}"
    for i in doc bin include; do mkdir -p "${instdir}/$i"; done

    cp -rf "${srcdir}"/doc/*.*       "${instdir}/doc/"
    cp -rf "${srcdir}"/src/*.exe     "${instdir}/bin/"
    cp -rf "${srcdir}"/src/*.dll     "${instdir}/bin/"
    cp -rf "${srcdir}"/src/luaconf.h "${instdir}/include/"
    cp -rf "${srcdir}"/src/lua.h     "${instdir}/include/"
    cp -rf "${srcdir}"/src/lualib.h  "${instdir}/include/"
    cp -rf "${srcdir}"/src/lauxlib.h "${instdir}/include/"
    cp -rf "${srcdir}"/src/lua.hpp   "${instdir}/include/"
}


#
# LOGIC
#


# If Lua is not installed...
if [ ! -f "${winec}/${dir_lua}/bin/lua.exe" ] ; then
    # If Lua sources are not downloaded..
    [ ! -d "${winec}${dir_src}/${luarel}" ] && download_lua ;
    compile_lua && install_lua;
fi

export WINEPATH="$(wdir "${dir_lua}/bin")"
wine lua -e "print(('\n\n%s: compiled! \n\n'):format(_VERSION))"
