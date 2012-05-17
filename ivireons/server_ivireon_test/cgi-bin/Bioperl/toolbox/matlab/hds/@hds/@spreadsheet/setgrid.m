function setgrid(this,vars)
%SETGRID  Defines underlying grid for gridded data sets.
%
%   SETGRID(S,VARS) specifies the independent variables in 
%   a spreadsheet object.  The independent variables VARS 
%   can be specified as
%    (1) a string or string vector containing the names of the  
%        variables for this grid dimension.
%    (2) a vector of @variable objects describing the variables 
%        for this grid dimension.
%
%   Example:
%      d = hds.spreadsheet({'x','y','z'})
%      d.setgrid('x'); 
%      d.x = [1 2 3];
%      d.y = [4 5 6];
%      d.z = {'a' 'b' 'c'};
% 
%   See also GETGRID.

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/08/20 16:36:14 $
ni = nargin;
if ni<2
   error('Not enough input arguments.')
elseif ni>2
   error('Spreadsheets have one-dimensional grids.')
end

% Locate specified variables
AllVars = getvars(this);
try
   idx = locate(AllVars,vars);
catch
   rethrow(lasterror)
end
this.Grid_(1).Variable = AllVars(idx)';
this.Grid_(1).Length = 0;
