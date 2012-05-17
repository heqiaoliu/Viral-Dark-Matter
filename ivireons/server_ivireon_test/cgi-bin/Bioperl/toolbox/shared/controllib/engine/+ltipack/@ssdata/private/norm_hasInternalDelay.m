function hasInternalDelay = norm_hasInternalDelay(D)
% Determine if internal delays are equivalent to input+output delays.
% Used for H2 and Linf norm computation.

%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:21 $

% RE: Can't directly compute diff(diff(iod,1,1),1,2) because
%     I/O delays for zero Hij(s) are always set to zero
[iod,nzio] = getIODelay(D);
if any(isnan(iod(:)))
   hasInternalDelay = true;
else
   [ny,nu] = size(iod);
   % Get maximum input and output delays, ignoring delays for 
   % identically zero I/O transfers
   iod(~nzio) = NaN;
   id = min(iod,[],1);
   od = min(iod-id(ones(ny,1),:),[],2);
   iodTarget = od(:,ones(1,nu)) + id(ones(ny,1),:);
   % Compare IOD and IODTARGET for nonzero I/O pairs
   idx = find(nzio);
   hasInternalDelay = any(abs(iod(idx)-iodTarget(idx))>1e3*eps*iod(idx));
end
