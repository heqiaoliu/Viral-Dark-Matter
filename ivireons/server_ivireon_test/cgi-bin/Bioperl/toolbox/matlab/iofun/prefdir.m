function dd_out = prefdir(createIfNecessary)
%PREFDIR Preference directory name.
%   D = PREFDIR  returns the name of the directory containing preferences
%   for MATLAB and related products, the command history file, the MATLAB 
%   shortcuts, and the MATLAB desktop layout files.  The existence of the 
%   directory is not ensured.
%
%   D = PREFDIR(1) creates the directory if it does not exist.
%
%   See also GETPREF, SETPREF.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.14.4.5 $  $Date: 2005/06/09 04:40:29 $

%   Converted to a builtin Feb. 28, 2005

