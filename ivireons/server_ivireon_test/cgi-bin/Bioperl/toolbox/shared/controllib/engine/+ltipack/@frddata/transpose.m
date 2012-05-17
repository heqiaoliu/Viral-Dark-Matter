function Dt = transpose(D)
% Transposition of FRD models.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:58 $
Dt = D;
Dt.Delay = transposeDelay(D);
[ny,nu,nf] = size(D.Response);
R = zeros(nu,ny,nf);
for ct=1:nf
   R(:,:,ct) = D.Response(:,:,ct).';
end
Dt.Response = R;