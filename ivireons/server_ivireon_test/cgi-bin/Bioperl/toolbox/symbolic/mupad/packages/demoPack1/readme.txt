This directory contains an example package for MuPAD.
=====================================================

See http://www.mupad.de/ for what MuPAD is.

This example package shows how to build a package containing library 
code, a dynamic module, English and German MuPAD online documentation.


Limitations:
------------

The online documentation and the Tar-Library can currently only be built
under Linux.  For a complete Windows build you need these steps under Linux
as preprocessing.  It suffices to build a linux installation and afterwards
run a Windows build in the same directory.


Files:
------

lib/                -- source of the library code of the package
makeDoc.sh          -- script which builda the documentation
make.sh             -- script which builds the modules and tar lib
readme.txt          -- this file
src/                -- directory containing module and documentation sources


generated files and directories:
doc/      -- the generated documentation files in language subdirectories
lib.tar   -- the library Tar file
lib.toc   -- an auxiliary library file
modules/  -- the generated modules in architecture subdirectories


Remark:
-------
To build the documentation, you need to have the MuPAD Documentation Developer
Kit installed (currently only available for Linux systems). Using a command
line shell, go to src/doc and invoke "make". This command creates the
documentation and places it into the doc/en directory. "make help" will
list more options.
