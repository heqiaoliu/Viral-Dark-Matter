function result = isunix()
%ISUNIX True for the UNIX version of MATLAB.
%   ISUNIX returns 1 for UNIX versions of MATLAB and 0 otherwise.
%
%   See also COMPUTER, ISPC, ISMAC.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.13.4.3 $  $Date: 2006/09/12 16:53:50 $

%  The only non-Unix platform is the PC
result = ~strncmp(computer,'PC',2);
