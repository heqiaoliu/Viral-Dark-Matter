function [U,S,V] = svd(A)
%SVD    Symbolic singular value decomposition.
%   With one output argument, SIGMA = SVD(A) is a symbolic vector 
%   containing the singular values of a symbolic matrix A.
%   SIGMA = SVD(VPA(A)) computes numeric singular values using
%   using variable precision arithmetic.
%
%   With three output arguments, both [U,S,V] = SVD(A) and
%   [U,S,V] = SVD(VPA(A)) return numeric unitary matrices U and V
%   whose columns are the singular vectors and a diagonal matrix S
%   containing the singular values.  Together, they satisfy
%   A = U*S*V'.  The singular vector computation uses variable
%   precision arithmetic and requires the input matrix to be numeric.
%   Symbolic singular vectors are not available.
%
%   Examples:
%      A = sym(magic(4))
%      svd(A)
%      svd(vpa(A))
%      [U,S,V] = svd(A)
%
%      syms t real
%      A = [0 1; -1 0]
%      E = expm(t*A)
%      sigma = svd(E)
%      simplify(sigma)
%
%   See also SVD, SYM/EIG, SYM/VPA.
 
%   Copyright 1993-2010 The MathWorks, Inc.

if all(size(A) == 1)

   % Monoelemental matrix

   if nargout < 2
      U = A;
   else
      U = sym(1);
      S = A;
      V = sym(1);
   end

elseif nargout < 2

    if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
    if isa(A.s,'maplesym')
        U = sym(svd(A.s));
    else
        U = mupadmex('symobj::svdvals',A.s);
    end

else
    if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
    if isa(A.s,'maplesym')
        [U,S,V] = svd(A.s);
        U = sym(U); S = sym(S); V = sym(V);
    else
        [U,S,V] = mupadmexnout('symobj::svdvecs',A);
    end
end
