function L = vertcat(L1,L2)
%VERTCAT  Metadata management in vertical concatenation.

%       Author(s):  P. Gahinet, 5-27-96
%       Copyright 1986-2007 The MathWorks, Inc.
%       $Revision: 1.1.6.3 $  $Date: 2007/12/14 14:23:33 $
L = L1;
if nargin==1,
   % Parser call to HORZCAT with single argument in [L ; SYSJ.dynamicsys]
   return
end

% Notes, Name, UserData
L = utClearUserData(L);

% Append output groups:
lind = length(L1.OutputName) + (1:length(L2.OutputName));
L.OutputGroup = groupcat(L1.OutputGroup,L2.OutputGroup,lind);
   
% Append output names
L.OutputName = [L1.OutputName ; L2.OutputName];

% InputName: check compatibility and merge
[L.InputName,InputNameClash] = mrgname(L1.InputName,L2.InputName);
if InputNameClash,
   ctrlMsgUtils.warning('Control:combination:InputNameClash')
   EmptyStr = {''};
   L.InputName = EmptyStr(ones(length(L.InputName),1),1);
end
   
% InputGroup: check compatibility 
[L.InputGroup,InputGroupClash] = mrggroup(L1.InputGroup,L2.InputGroup);
if InputGroupClash,
    ctrlMsgUtils.warning('Control:combination:InputGroupClash')
   L.InputGroup = struct;
end

