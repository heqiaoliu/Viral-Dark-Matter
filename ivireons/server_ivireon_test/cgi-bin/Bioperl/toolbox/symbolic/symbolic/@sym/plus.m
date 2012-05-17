function X = plus(A, B)
%PLUS   Symbolic addition.
%   PLUS(A,B) overloads symbolic A + B.
    
%   Copyright 1993-2010 The MathWorks, Inc.

if ~isa(A,'sym'), A = sym(A); end
if ~isa(B,'sym'), B = sym(B); end
if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
if builtin('numel',B) ~= 1,  B = normalizesym(B);  end
if isa(A.s,'maplesym')
    X = sym(A.s + B.s);
else
    X = mupadmex('symobj::zip',A.s,B.s,'_plus');
end
