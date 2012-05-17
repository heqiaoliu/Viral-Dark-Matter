function L = utDiag(L)
% Metadata management in DIAG interconnection.

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 14:23:25 $
% Notes and UserData
L = utClearUserData(L);

% I/O groups
L.InputGroup = struct;
L.OutputGroup = struct;

% I/O names
n = length(L.InputName)*length(L.OutputName);
L.InputName = repmat({''},n,1);
L.OutputName = repmat({''},n,1);
