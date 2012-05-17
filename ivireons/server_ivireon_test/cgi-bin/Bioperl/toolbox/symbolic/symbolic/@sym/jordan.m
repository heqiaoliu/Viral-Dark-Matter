function [V,J] = jordan(A)
%JORDAN   Jordan Canonical Form.
%   JORDAN(A) computes the Jordan Canonical/Normal Form of the matrix A.
%   The matrix must be known exactly, so its elements must be integers,
%   or ratios of small integers.  Any errors in the input matrix may
%   completely change its JCF.
%
%   [V,J] = JORDAN(A) also computes the similarity transformation, V, so
%   that V\A*V = J.  The columns of V are the generalized eigenvectors.
%
%   Example:
%      A = sym(gallery(5));
%      [V,J] = jordan(A)
%
%   See also SYM/EIG, SYM/POLY.

%   Copyright 1993-2010 The MathWorks, Inc.

if ~isa(A,'sym'), A = sym(A); end
if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
if all(size(A) == 1)
   if nargout <= 1
      V = A;
   else
      J = A;
      V = sym(1);
   end
else
    if nargout <= 1
        if isa(A.s,'maplesym')
            V = sym(jordan(A.s));
        else
            V = mupadmex('symobj::jordan',A.s);
        end
    else
        if isa(A.s,'maplesym')
            [V,J] = jordan(A.s);
            V = sym(V); J = sym(J);
        else
            [V,J] = mupadmexnout('symobj::jordan',A,'All');
        end
    end
end

