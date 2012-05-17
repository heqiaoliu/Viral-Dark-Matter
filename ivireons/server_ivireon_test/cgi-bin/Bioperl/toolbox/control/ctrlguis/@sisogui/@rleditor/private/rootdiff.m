function rG = rootdiff(rOL,rC)
% Set differencing with inexact matches

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/11/17 13:25:52 $
nC = length(rC);
nOL = length(rOL);
if nC>nOL
   % Should not happen
   rG = zeros(0,1);
else
   gaps = abs(rOL(:,ones(1,nC))-rC(:,ones(1,nOL)).');
   [junk,jC] = sort(min(gaps,[],1));
   % OL2C(i) = j if the ith-entry of rOL is matched with the j-th entry of rC
   OL2C = zeros(nOL,1);
   for ct=1:nC
      j = jC(ct);
      ifree = find(OL2C==0);
      [junk,imin] = min(gaps(ifree,j)); % find best match for j-th entry of C
      OL2C(ifree(imin)) = j;
   end
   rG = rOL(OL2C==0);
end


