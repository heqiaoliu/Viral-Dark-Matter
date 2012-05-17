function C = mod(A,B)
%MOD    Symbolic matrix element-wise mod.
%   C = MOD(A,B) for symbolic matrices A and B with integer elements
%   is the positive remainder in the element-wise division of A by B.  
%   For matrices A with polynomial entries, MOD(A,B) is applied to the
%   individual coefficients.
%
%   Examples:
%      ten = sym('10');
%      mod(2^ten,ten^3)
%      24
%
%      syms x
%      mod(x^3-2*x+999,10)
%      x^3+8*x+9
%
%   See also SYM/QUOREM.

%   Copyright 1993-2010 The MathWorks, Inc.

if ~isa(A,'sym'), A = sym(A); end
if ~isa(B,'sym'), B = sym(B); end
if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
if builtin('numel',B) ~= 1,  B = normalizesym(B);  end
if isa(A.s,'maplesym')
    C = sym(mod(A.s,B.s));
else
    C = mupadmex('symobj::zip',A.s,B.s,'symobj::modp');
end
