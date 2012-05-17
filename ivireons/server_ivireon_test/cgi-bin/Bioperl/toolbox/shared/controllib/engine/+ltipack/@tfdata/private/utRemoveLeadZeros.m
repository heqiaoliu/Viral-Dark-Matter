function [num,den] = utRemoveLeadZeros(num,den)
% Eliminates common leading zeros created by operations like s * 1/s

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:19 $
for ct=1:numel(num)
   i = find(num{ct}~=0 | den{ct}~=0);
   if i(1)>1
      num{ct}(1:i(1)-1) = [];
      den{ct}(1:i(1)-1) = [];
   end
end
