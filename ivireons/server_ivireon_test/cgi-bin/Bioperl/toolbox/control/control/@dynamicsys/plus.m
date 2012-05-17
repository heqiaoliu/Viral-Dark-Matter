function L = plus(L1,L2)
%PLUS  Meta data management for system addition.

%   Author(s):  P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 14:23:16 $
EmptyStr = {''};
L = utClearUserData(L1);

% InputName
[L.InputName,clash] = mrgname(L1.InputName,L2.InputName);
if clash,
    ctrlMsgUtils.warning('Control:combination:InputNameClash')
    L.InputName = EmptyStr(ones(length(L1.InputName),1),1);
end

% InputGroup: check compatibility 
[L.InputGroup,clash] = mrggroup(L1.InputGroup,L2.InputGroup);
if clash, 
    ctrlMsgUtils.warning('Control:combination:InputGroupClash')
    L.InputGroup = struct;
end

% OutputName
[L.OutputName,clash] = mrgname(L1.OutputName,L2.OutputName);
if clash,
    ctrlMsgUtils.warning('Control:combination:OutputNameClash')
    L.OutputName = EmptyStr(ones(length(L1.OutputName),1),1);
end

% InputGroup: check compatibility 
[L.OutputGroup,clash] = mrggroup(L1.OutputGroup,L2.OutputGroup);
if clash, 
    ctrlMsgUtils.warning('Control:combination:OutputGroupClash')
    L.OutputGroup = struct;
end