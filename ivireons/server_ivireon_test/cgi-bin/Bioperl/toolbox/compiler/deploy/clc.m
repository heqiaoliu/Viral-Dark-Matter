function status = clc
%CLC clears the command window.
%   This is a no-op function corresponding to the CLC function 
%   available in MATLAB. 

% Copyright 2004 The MathWorks, Inc.

   warning('Compiler:NoClc', ....
           'The CLC function will do nothing in compiled applications.' );

   % Always fail
   status = 1;