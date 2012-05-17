function D = diag(D)
% Turns Nx1 FRD into NxN diagonal.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:17 $
D = elimDelay(D);
[ny,nu,nf] = size(D.Response);
n = ny*nu;
R = zeros(n,n,nf);
for ct=1:nf
   R(:,:,ct) = diag(D.Response(:,:,ct));
end
D.Response = R;
D.Delay = ltipack.utDelayStruct(n,n,false);
