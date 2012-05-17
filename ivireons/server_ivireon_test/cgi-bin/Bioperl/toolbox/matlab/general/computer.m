%COMPUTER Computer type.
%   C = COMPUTER returns string C denoting the type of computer
%   on which MATLAB is executing. Possibilities are:
%
%                                             ISPC ISUNIX ISMAC ARCHSTR    
%   32-Bit Platforms
%     PCWIN    - Microsoft Windows on x86       1     0     0   win32
%     GLNX86   - Linux on x86                   0     1     0   glnx86
%
%   64-Bit Platforms
%     PCWIN64  - Microsoft Windows on x64       1     0     0   win64
%     GLNXA64  - Linux on x86_64                0     1     0   glnxa64
%     MACI64   - Apple Mac OS X on x86_64       0     1     1   maci64
% 
%   ARCHSTR = COMPUTER('arch') returns string ARCHSTR which is 
%   used by the MEX command -arch switch.
%
%   [C,MAXSIZE] = COMPUTER returns integer MAXSIZE which 
%   contains the maximum number of elements allowed in a matrix
%   on this version of MATLAB.
%
%   [C,MAXSIZE,ENDIAN] = COMPUTER returns either 'L' for
%   little endian byte ordering or 'B' for big endian byte ordering.
%
%   See also ISPC, ISUNIX, ISMAC.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.18.4.13 $  $Date: 2010/03/08 21:41:01 $
%   Built-in function.

