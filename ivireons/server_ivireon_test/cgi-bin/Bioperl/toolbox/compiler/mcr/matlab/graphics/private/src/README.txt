This contains information for building tex related files.

1) Auto-generating initex.c 
Note: Rebuilding initex.c is required only if modifying initex.ch
-Do the following in unix: 
   tangle tex.web initex.ch
-Use the pascal to C translator: 
   p2c tex.p
-Start MATLAB and run the following to post process the c source: 
   pt tex.c initex.c
-In initex.c, replace 
      #include <p2c/p2c.h> 
  with  
      #include "p2c.h" 
-In texmex.c, add: 
       #define INITEX
  at the top of the file.

2) Building mex files: mlinitex, texmex 
   setmwe Amin
   gmake 

3) Building plain.fmt 
-plain.fmt is a tex memory dump file that is specific to big endian
 and small endian machines. Big endian means the most significant byte 
 in a primitive multi-byte datatype (like an integer) comes first.  
-To create a big endian format file, run on solaris,hpux, or mac. For a 
 small endian format file, run on an intel box (glnx86 or Windows)
-Run texutil('buildplain')
-Rename texput.dvi to plain.fmt
-Move plain.fmt into the matlab/sys/tex/format directory

4) Building latex.fmt
-This file is similar to plain.fmt, but contains latex macros
 which are built on top of the plain.tex macros.
-Unzip base.zip and required.zip in the matlab/sys/tex/latex directory
-Unpack files in the macros/latex/base directory by 
 running 'initex unpack.ins' at the command prompt.
-Run texutil('buildlatex')
-Rename texput.dvi to latex.fmt
-Move plain.fmt into the matlab/sys/tex/format directory

5) TeX Conformance Test
-Run this test after major changes to TeX implementation
-Run texutil('testtex')
-Compare output with *.reference files located in test_tex subdirectory
-Consult trip.tex for more information on verifying TeX

6) LaTeX Conformance Test
-Run this test after major changes to LaTeX implementation
-Run texutil('testlatex')
-Output log should pass all test points, an "OK" should appear 
