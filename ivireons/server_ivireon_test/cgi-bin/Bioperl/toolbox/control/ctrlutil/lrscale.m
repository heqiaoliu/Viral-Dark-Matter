function X = lrscale(X,L,R)
%LRSCALE  Applies left and right scaling matrices.
%
%   Y = LRSCALE(X,L,R) forms Y = diag(L) * X * diag(R) in 
%   2mn flops if X is m-by-n.  L=[] or R=[] is interpreted
%   as the identity matrix.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2010/03/31 18:13:39 $
[m,n] = size(X);
LS = (numel(L)>0);
RS = (numel(R)>0);
if LS && RS
   for j=1:n
      Rj = R(j);
      for i=1:m
         X(i,j) = (L(i) * Rj) * X(i,j);
      end
   end
elseif LS
   for i=1:m
      Li = L(i);
      for j=1:n
         X(i,j) = Li * X(i,j);
      end
   end
elseif RS
   for j=1:n
      Rj = R(j);
      for i=1:m
         X(i,j) = X(i,j) * Rj;
      end
   end
end
