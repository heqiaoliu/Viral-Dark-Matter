function L = horzcat(L1,L2)
%HORZCAT  Metadata management in horizontal concatenation.

%   Author(s):  P. Gahinet, 5-27-96
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 14:23:12 $
L = L1;
if nargin==1,
   % Parser call to HORZCAT with single argument in [L , SYSJ.dynamicsys]
   return
end

% Notes, Name, UserData
L = utClearUserData(L);

% Append input groups:
lind = length(L.InputName) + (1:length(L2.InputName));
L.InputGroup = groupcat(L1.InputGroup,L2.InputGroup,lind);

% Append input names
L.InputName = [L1.InputName ; L2.InputName];

% OutputName: check compatibility and merge
[L.OutputName,OutputNameClash] = mrgname(L1.OutputName,L2.OutputName);
if OutputNameClash,
   ctrlMsgUtils.warning('Control:combination:OutputNameClash')
   EmptyStr = {''};
   L.OutputName = EmptyStr(ones(length(L.OutputName),1),1);
end

% OutputGroup: check compatibility 
[L.OutputGroup,OutputGroupClash] = mrggroup(L1.OutputGroup,L2.OutputGroup);
if OutputGroupClash,
    ctrlMsgUtils.warning('Control:combination:OutputGroupClash')
    L.OutputGroup = struct;
end

