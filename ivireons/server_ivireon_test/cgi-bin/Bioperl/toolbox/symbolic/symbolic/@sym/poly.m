function p = poly(A,x)
%POLY   Symbolic characteristic polynomial.
%   POLY(A) computes the characteristic polynomial of the SYM matrix A.
%   The result is a symbolic polynomial in 'x' or 't'.
%
%   POLY(A,v) uses 'v' instead of 'x'. v is a SYM.
%
%   Example:  
%      poly([a b; c d]) returns x^2 + (- a - d)*x + a*d - b*c
%
%   See also SYM/POLY, SYM/POLY2SYM, SYM/SYM2POLY, SYM/JORDAN, SYM/EIG, SYM/SOLVE.

%   Copyright 1993-2010 The MathWorks, Inc.

if ~isa(A,'sym'), A = sym(A); end
if builtin('numel',A) ~= 1,  A = normalizesym(A);  end

if isa(A.s,'maplesym')
    if nargin < 2
        p = sym(poly(A.s));
    else
        if ~isa(x,'sym')
            x = sym(x);
        end
        p = sym(poly(A.s,x.s));
    end
    return;
end    
if nargin < 2
   s = symvar(A);
   if any(s==sym('x'))
      x = sym('t');
   else
      x = sym('x');
   end
end
if ischar(x), x = sym(x); end
p = mupadmex('symobj::charpoly',A.s,x.s);

