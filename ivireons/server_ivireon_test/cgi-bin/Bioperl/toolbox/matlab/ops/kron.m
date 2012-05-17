function K = kron(A,B)
%KRON   Kronecker tensor product.
%   KRON(X,Y) is the Kronecker tensor product of X and Y.
%   The result is a large matrix formed by taking all possible
%   products between the elements of X and those of Y. For
%   example, if X is 2 by 3, then KRON(X,Y) is
%
%      [ X(1,1)*Y  X(1,2)*Y  X(1,3)*Y
%        X(2,1)*Y  X(2,2)*Y  X(2,3)*Y ]
%
%   If either X or Y is sparse, only nonzero elements are multiplied
%   in the computation, and the result is sparse.
%
%   Class support for inputs X,Y:
%      float: double, single

%   Thanks Paul Fackler and Jordan Rosenthal for previous versions.
%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 5.17.4.3 $ $Date: 2009/01/30 14:42:23 $

if ndims(A) > 2 || ndims(B) > 2
    error('MATLAB:kron:TwoDInput','Inputs must be 2-D.');
end

[ma,na] = size(A);
[mb,nb] = size(B);

if ~issparse(A) && ~issparse(B)

   % Both inputs full, result is full.

   [ia,ib] = meshgrid(1:ma,1:mb);
   [ja,jb] = meshgrid(1:na,1:nb);
   K = A(ia,ja).*B(ib,jb);

else

   % At least one input is sparse, result is sparse.

   [ia,ja,sa] = find(A);
   [ib,jb,sb] = find(B);
   ia = ia(:); ja = ja(:); sa = sa(:);
   ib = ib(:); jb = jb(:); sb = sb(:);
   ka = ones(size(sa));
   kb = ones(size(sb));
   t = mb*(ia-1)';
   ik = t(kb,:)+ib(:,ka);
   t = nb*(ja-1)';
   jk = t(kb,:)+jb(:,ka);
   K = sparse(ik,jk,sb*sa.',ma*mb,na*nb);

end
