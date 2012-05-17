function L = utStack(L1,L2)
% Metadata management for stacking of dynamic systems.

%   Author(s):  P. Gahinet, 5-27-96
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 14:23:32 $
L = utClearUserData(L1);

% I/O channel names should match 
[L.InputName,InputNameClash] = mrgname(L1.InputName,L2.InputName);
if InputNameClash,
   ctrlMsgUtils.warning('Control:combination:InputNameClash')
   L.InputName(:,1) = {''}; 
end

[L.OutputName,OutputNameClash] = mrgname(L1.OutputName,L2.OutputName);
if OutputNameClash,
   ctrlMsgUtils.warning('Control:combination:OutputNameClash')
   L.OutputName(:,1) = {''}; 
end

% I/O groups should match
[L.InputGroup,InputGroupClash] = mrggroup(L1.InputGroup,L2.InputGroup);
if InputGroupClash,
   ctrlMsgUtils.warning('Control:combination:InputGroupClash')
   L.InputGroup = struct;
end

[L.OutputGroup,OutputGroupClash] = mrggroup(L1.OutputGroup,L2.OutputGroup);
if OutputGroupClash,
   ctrlMsgUtils.warning('Control:combination:OutputGroupClash')
   L.OutputGroup = struct;
end