function Report = arecheckout(X1,X2,Success,Ls)
% Checks for proper extraction of stable invariant subspace.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2009/08/08 01:09:06 $
X12 = X1'*X2;
Asym = norm(X12-X12',1); % solution asymmetry
n = size(X1,1);

if ~Success || any(~Ls(1:n,:)) || any(Ls(n+1:2*n,:)) || Asym > max(1e3*eps,0.1*norm(X12,1))
   % Could not (reliably) isolate stable invariant subspace of dimension n
   Report = -1;
else
   Report = 0;
   if Asym > sqrt(eps),
       ctrlMsgUtils.warning('Control:foundation:RiccatiAccuracy')
   end
end
