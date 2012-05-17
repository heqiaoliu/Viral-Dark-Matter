function [c,t] = coeffs(p,x)
%COEFFS Coefficients of a multivariate polynomial.
%   C = COEFFS(P) returns the coefficients of the polynomial P with
%   respect to all the indeterminates of P.
%   C = COEFFS(P,X) returns the coefficients of the polynomial P with
%   respect to X.
%   [C,T] = COEFFS(P,...) also returns an expression sequence of the
%   terms of P.  There is a one-to-one correspondence between the
%   coefficients and the terms of P. 
%
%   Examples:
%      syms x
%      t = 2 + (3 + 4*log(x))^2 - 5*log(x);
%      coeffs(expand(t)) = [ 11, 19, 16]      
%
%      syms a b c x
%      y = a + b*sin(x) + c*sin(2*x)
%      coeffs(y,sin(x)) = [a + c*sin(2*x), b]
%      coeffs(expand(y),sin(x)) = [a, b + 2*c*cos(x)]
%      
%      syms x y
%      z = 3*x^2*y^2 + 5*x*y^3
%      coeffs(z) = [5, 3] 
%      coeffs(z,x) = [5*y^3, 3*y^2]
%      [c,t] = coeffs(z,y) returns c = [5*x, 3*x^2], t = [y^3, y^2]
%
%   See also SYM/SYM2POLY.

%   Copyright 1993-2010 The MathWorks, Inc.

p = sym(p);
if builtin('numel',p) ~= 1,  p = normalizesym(p);  end
if nargin == 2
    x2 = sym(x);
    args = {x2.s};
else
    args = {};
end
if isa(p.s,'maplesym')
    if nargout == 2
        [c,t] = coeffs(p.s,args{:});
        c = sym(c);
        t = sym(t);
    else
        c = sym(coeffs(p.s, args{:}));
    end
else
    if nargout < 2
        c = mupadmex('symobj::coeffs',p.s, args{:});
    else
        [c,t] = mupadmexnout('symobj::coeffsterms', p, args{:});
    end
end
