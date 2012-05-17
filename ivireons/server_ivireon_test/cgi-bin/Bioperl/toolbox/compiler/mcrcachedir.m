function d = mcrcachedir
% MCRCACHEDIR Return the location of the MCR component cache
%   
%   D = MCRCACHEDIR Calculates and returns the full path to the MCR 
%   component cache directory.  This is the location used by the MCR to 
%   unpack embedded CTF data.  
%  
%   The default location may be overridden by setting the environment 
%   variable MCR_CACHE_ROOT.  If this variable is defined, then MCRCACHEDIR
%   will append a version-specific subdirectory name to the value of 
%   MCR_CACHE_ROOT and return the resulting path.
%  
%   The contents of the cache may be safely reset when no compiled 
%   applications or components are in use by deleting the directory named 
%   by MCRCACHEDIR.

%#mex
error('MATLAB:mcrcachedir:MissingMexFile','MEX file not present');

% Copyright 2007 The MathWorks, Inc.
