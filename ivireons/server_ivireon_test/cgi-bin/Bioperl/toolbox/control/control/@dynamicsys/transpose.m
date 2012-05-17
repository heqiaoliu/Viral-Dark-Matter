function L = transpose(L)
% Metadata management in SYS.' and SYS'

%   Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/12/14 14:23:21 $
L = utClearUserData(L);

% Delete I/O names and groups
EmptyStr = {''};
ny = length(L.OutputName);
nu = length(L.InputName);
L.InputName = EmptyStr(ones(ny,1),:);
L.OutputName = EmptyStr(ones(nu,1),:);
L.InputGroup = struct;
L.OutputGroup = struct;
