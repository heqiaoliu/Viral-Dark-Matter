%MATLABPATH Search path.
%   MATLABPATH is the built-in function that gets/sets the search path.
%   Please use the M-file PATH instead since it validates the path
%   elements and provides a much easier way to change the path. The path
%   is a PATHSEP character separated list of directories that MATLAB
%   searches when looking for functions and other files.
%
%   MATLABPATH, by itself, prettyprints MATLAB's current search path. 
%   P = MATLABPATH returns a string containing the path in P.
%   MATLABPATH(P) changes the path to P. 
%
%   See also PATH, PATHSEP.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $  $Date: 2005/06/27 22:47:16 $
%   Built-in function.
