Axa Lua development tools through Wine
======================================

This folder contains helpers for:

* Compiling Lua 5.1, 5.2, 5.3, 5.4 for windows through Wine
* Compiling Luarocks

It should work on any Linux with Wine since you already had
mingw32-gcc installed via Wine.



Requirements
------------

* Wine 32bits
* TDM-GCC 32 bits installed under C:/TDM-GCC-32 under Wine C drive
* Internet connection (for Lua sources download)



Limitations on Luarocks
-----------------------

Luarocks actually doesn't build or install anything. It is installed, but
unused. It occurs due to a bug of Luarocks or Wine about permissions to create
and write on directories.

It shouldn't prevent you from testing your packages. This is also a good way to
you provide simple tests, and avoid dependencies from other Lua modules (as you
wont have the usable Luarocks).

Stop, relax and breathe... you need to test if some C thing works with Lua.
Don't let Windows license or Wine/Luarocks limitations ruin your day. :)

