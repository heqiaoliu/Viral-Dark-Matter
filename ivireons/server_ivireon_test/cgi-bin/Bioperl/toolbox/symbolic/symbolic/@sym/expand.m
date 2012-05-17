function r = expand(s)
%EXPAND Symbolic expansion.
%   EXPAND(S) writes each element of a symbolic expression S as a
%   product of its factors.  EXPAND is most often used on polynomials,
%   but also expands trigonometric, exponential and logarithmic functions.
%
%   Examples:
%      expand((x+1)^3)   returns  x^3+3*x^2+3*x+1
%      expand(sin(x+y))  returns  sin(x)*cos(y)+cos(x)*sin(y)
%      expand(exp(x+y))  returns  exp(x)*exp(y)
%
%   See also SYM/SIMPLIFY, SYM/SIMPLE, SYM/FACTOR, SYM/COLLECT.

%   Copyright 1993-2010 The MathWorks, Inc.

if builtin('numel',s) ~= 1,  s = normalizesym(s);  end
if isa(s.s,'maplesym')
    r = sym(expand(s.s));
else
    r = mupadmex('symobj::map',s.s,'expand');
end
