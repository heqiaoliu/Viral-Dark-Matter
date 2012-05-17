function [g,c,d] = gcd(a,b,x)
%GCD    Greatest common divisor.
%   G = GCD(A,B) is the symbolic greatest common divisor of A and B.
%   G = GCD(A,B,X) uses variable X instead of SYMVAR(A,1).
%   [G,C,D] = GCD(A,B,...) also returns C and D so that G = A*C + B*D.
%
%   Example:
%      syms x
%      gcd(x^3-3*x^2+3*x-1,x^2-5*x+4) 
%      returns x-1
%
%   See also SYM/LCM.

%   Copyright 1993-2010 The MathWorks, Inc.
 
if ~isa(a,'sym'), a = sym(a); end
if builtin('numel',a) ~= 1,  a = normalizesym(a);  end
if ~isa(b,'sym'), b = sym(b); end
if builtin('numel',b) ~= 1,  b = normalizesym(b);  end
if isa(a.s,'maplesym')
    if nargin < 3
        args = {a.s,b.s};
    else
        args = {a.s,b.s,x.s};
    end
    if nargout <= 1
        g = sym(gcd(args{:}));
    else
        [g,c,d] = gcd(args{:});
        g = sym(g); c = sym(c); d = sym(d);
    end
else
    if nargin < 3
        x = symvar(a,1);
        if ~isequal(x,symvar(b,1))
            error('symbolic:sym:gcd:errmsg1','Cannot identify default symbolic variable.')
        end
    end
    if isempty(x) && nargout <= 1
        g = mupadmex('gcd',a.s,b.s);
    else
        if isempty(x)
            [g,c,d] = mupadmexnout('symobj::igcdex',a,b);
        else
            if ischar(x), x = sym(x); end
            [g,c,d] = mupadmexnout('symobj::gcdex',a,b,x);
        end
    end
end
