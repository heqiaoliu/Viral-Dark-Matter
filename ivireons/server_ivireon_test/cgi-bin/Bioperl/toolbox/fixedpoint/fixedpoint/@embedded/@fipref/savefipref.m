function savefipref(this)
%SAVEFIPREF Save fixed-point preferences
%   SAVEFIPREF(P) Saves the fixed-point preferences object P to the
%   preferences file so that it will be persistent between MATLAB
%   sessions.

%   Thomas A. Bryan, 7 March 2003
%   Copyright 2003-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2006/12/20 07:13:17 $

% Save the struct of the fipref object to prevent
% an error if the Fixed-point Toolbox or its license
% is missing when MATLAB/getpref is called    

% Remove the DataTypeOverride field so that it doesn't affect the
% math when users are sharing their fi code.
s = rmfield(struct(this),'DataTypeOverride');
setpref('embedded','fipref',s);

