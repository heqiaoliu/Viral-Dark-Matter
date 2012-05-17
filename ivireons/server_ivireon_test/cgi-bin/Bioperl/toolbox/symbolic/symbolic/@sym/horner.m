function r = horner(p)
%HORNER Horner polynomial representation.
%   HORNER(P) transforms the symbolic polynomial P into its Horner,
%   or nested, representation.
%
%   Example:
%       horner(x^3-6*x^2+11*x-6) returns
%           x*(x*(x-6)+11)-6

%   See Also SIMPLIFY, SIMPLE, FACTOR, COLLECT.

%   Copyright 1993-2010 The MathWorks, Inc.

if builtin('numel',p) ~= 1,  p = normalizesym(p);  end
if isa(p.s,'maplesym')
    r = sym(horner(p.s));
else
    r = mupadmex('symobj::map',p.s,'symobj::horner');
end

