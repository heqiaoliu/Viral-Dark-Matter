function g = finverse(f,x)
%FINVERSE Functional inverse.
%   g = FINVERSE(f) returns the functional inverse of f. 
%   f is a scalar sym representing a function of exactly 
%   one symbolic variable, say 'x'. Then g is a scalar sym
%   that satisfies g(f(x)) = x.
%
%   g = FINVERSE(f,v) uses the symbolic variable v, where v is
%   a sym, as the independent variable. Then g is a scalar 
%   sym that satisfies g(f(v)) = v. Use this form when f contains 
%   more than one symbolic variable.
%
%   If no inverse can be found g is either the empty sym object
%   or, if f is a polynomial, a RootOf expression.
%
%   Examples:
%      finverse(1/tan(x)) returns atan(1/x).
%
%      f = x^2+y;
%      finverse(f,y) returns y - x^2.
%      finverse(f) returns (x - y)^(1/2) and a warning that the 
%         inverse is not unique.
%
%   See also SYM/COMPOSE.

%   Copyright 1993-2010 The MathWorks, Inc.

if ~isa(f,'sym'), f = sym(f); end
if builtin('numel',f) ~= 1,  f = normalizesym(f);  end
if nargin == 2
   x = sym(x);
   if builtin('numel',x) ~= 1,  x = normalizesym(x);  end
else
   x = symvar(f,1);
   if isempty(x), error('symbolic:sym:finverse:errmsg1','Functional inverse does not exist.'); end;
end;

if isa(f.s,'maplesym')
    g = sym(finverse(f.s,char(x)));
else
    g = mupadmex('symobj::finverse',f.s,x.s);
end
