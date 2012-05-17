function L = utRepSys(L,s)
% Metadata management for REPSYS

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 14:23:31 $
L = utClearUserData(L);
[ny,nu] = iosize(L);
if isscalar(s)
   s = [s s];
end
L.InputName = repmat({''},nu*s(2),1);
L.OutputName = repmat({''},ny*s(1),1);
L.InputGroup = struct;
L.OutputGroup = struct;
