function p = poly2sym(c,x)
%POLY2SYM Polynomial coefficient vector to symbolic polynomial.
%   POLY2SYM(C,V) is a polynomial in the symbolic variable V
%   with coefficients from the vector C.
% 
%   Example:
%       x = sym('x');
%       poly2sym([1 0 -2 -5],x)
%   is
%       x^3-2*x-5
%
%   See also SYM/SYM2POLY, POLYVAL.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/02/09 00:31:41 $

eng = symengine;
if strcmp(eng.kind,'maple')
    if isa(c,'sym')
        if builtin('numel',c) ~= 1,  c = normalizesym(c);  end
        c = c.s;
    end
    if nargin == 2
        if ~isa(x,'sym')
            x = sym(x);
        end
        if builtin('numel',x) ~= 1,  x = normalizesym(x);  end
        p = sym(poly2sym(c,x.s));
    else
        p = sym(poly2sym(c));
    end
else
    if ~isa(c,'sym'), c = sym(c); end
    if isa(x,'sym')
        if builtin('numel',x) ~= 1,  x = normalizesym(x);  end
        cx = x.s;  
    else
        cx = x;  
    end
    p = mupadmex('symobj::poly2sym',c.s,cx);
end
