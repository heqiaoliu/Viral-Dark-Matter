function D = diagrep(D,k)
% Replicates model along the diagonal.
%
%   D = DIAGREP(D,K) forms the block-diagonal model Diag(D,...,D) with 
%   D repeated K times.

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:00 $
[ny,nu] = size(D.num);
num = cell(k*ny,k*nu);  num(:) = {0};
den = cell(k*ny,k*nu);  den(:) = {1};
iod = zeros(k*ny,k*nu);
ix = 0; jx = 0;
for j=1:k,
   num(ix+1:ix+ny,jx+1:jx+nu) = D.num;
   den(ix+1:ix+ny,jx+1:jx+nu) = D.den;
   iod(ix+1:ix+ny,jx+1:jx+nu) = D.Delay.IO;
   ix = ix+ny;  jx = jx+nu;
end
D.num = num;
D.den = den;
D.Delay.Input = repmat(D.Delay.Input,[k 1]);
D.Delay.Output = repmat(D.Delay.Output,[k 1]);
D.Delay.IO = iod;
