function c = lcm(a,b)
%LCM    Least common multiple.
%   C = LCM(A,B) is the symbolic least common multiple of A and B.
%
%   Example:
%      syms x
%      factor(lcm(x^3-3*x^2+3*x-1,x^2-5*x+4))
%      returns (x-1)^3*(x-4)
%
%   See also SYM/GCD.

%   Copyright 1993-2010 The MathWorks, Inc.

if ~isa(a,'sym'), a = sym(a); end
if builtin('numel',a) ~= 1,  a = normalizesym(a);  end
if ~isa(b,'sym'), b = sym(b); end
if builtin('numel',b) ~= 1,  b = normalizesym(b);  end
if isa(a.s,'maplesym')
    c = sym(lcm(a.s,b.s));
else
    c = mupadmex('lcm',a.s,b.s);
end

