function L = mtimes(L1,L2)
%MTIMES  Metadata management for dynamic system product.

%   Author(s):  P. Gahinet, 5-23-96
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/14 14:23:15 $
[ny1,nu1] = iosize(L1);
[ny2,nu2] = iosize(L2); %#ok<NASGU>
if nu1==1 && ny2~=1
   % Scalar multiplication sys1*SYS2 (keep Notes and UserData)
   L = L2;
elseif nu1~=1 && ny2==1
   % Scalar multiplication SYS1*sys2;
   L = L1;
else
   % Regular multiplication
   L = utClearUserData(L2);  % Takes care of InputName and InputGroup
   % Output names and groups
   L.OutputName = L1.OutputName; 
   L.OutputGroup = L1.OutputGroup;
end
