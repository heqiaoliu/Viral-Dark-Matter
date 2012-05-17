function D = diagrep(D,k)
% Replicates model along the diagonal.
%
%   D = DIAGREP(D,K) forms the block-diagonal model Diag(D,...,D) with 
%   D repeated K times.

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:37 $
I = eye(k);
D.a = kron(I,D.a);
if ~isempty(D.e)
   D.e = kron(I,D.e);
end
D.StateName = repmat(D.StateName,[k 1]);
D.Delay.Input = repmat(D.Delay.Input,[k 1]);
D.Delay.Output = repmat(D.Delay.Output,[k 1]);
nfd = length(D.Delay.Internal);
if nfd==0
   D.b = kron(I,D.b);
   D.c = kron(I,D.c);
   D.d = kron(I,D.d);
else
   [rs,cs] = size(D.d);
   nu = cs-nfd;
   ny = rs-nfd;
   D.b = [kron(I,D.b(:,1:nu)) , kron(I,D.b(:,nu+1:cs))];
   D.c = [kron(I,D.c(1:ny,:)) ; kron(I,D.c(ny+1:rs,:))];
   D.d = [kron(I,D.d(1:ny,1:nu)) kron(I,D.d(1:ny,nu+1:cs)) ; ...
      kron(I,D.d(ny+1:rs,1:nu)) kron(I,D.d(ny+1:rs,nu+1:cs))];
   D.Delay.Internal = repmat(D.Delay.Internal,[k 1]);
end
