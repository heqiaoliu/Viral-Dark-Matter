function L = times(L1,L2)
%TIMES  Metadata management for L1.*L2 product.

%   Author(s):  P. Gahinet, 5-23-96
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2007/12/14 14:23:20 $
[ny1,nu1] = iosize(L1);
[ny2,nu2] = iosize(L2);
if (nu1==1 && ny1==1) && (nu2~=1 || ny2~=1)
   % Scalar multiplication sys1*SYS2 (keep Notes and UserData)
   L = L2;
elseif (nu2==1 && ny2==1) && (nu1~=1 || ny1~=1)
   % Scalar multiplication SYS1*sys2;
   L = L1;
else
   % Regular dot product
   L = utClearUserData(L1);

   % InputName: check compatibility and merge
   [L.InputName,InputNameClash] = mrgname(L1.InputName,L2.InputName);
   if InputNameClash,
      ctrlMsgUtils.warning('Control:combination:InputNameClash')
      L.InputName(:) = {''};
   end

   % InputGroup: check compatibility
   [L.InputGroup,InputGroupClash] = mrggroup(L1.InputGroup,L2.InputGroup);
   if InputGroupClash,
      ctrlMsgUtils.warning('Control:combination:InputGroupClash')
      L.InputGroup = struct;
   end

   % OutputName: check compatibility and merge
   [L.OutputName,OutputNameClash] = mrgname(L1.OutputName,L2.OutputName);
   if OutputNameClash,
      ctrlMsgUtils.warning('Control:combination:OutputNameClash')
      L.OutputName(:) = {''};
   end

   % OutputGroup: check compatibility
   [L.OutputGroup,OutputGroupClash] = mrggroup(L1.OutputGroup,L2.OutputGroup);
   if OutputGroupClash,
      ctrlMsgUtils.warning('Control:combination:OutputGroupClash')
      L.OutputGroup = struct;
   end
end