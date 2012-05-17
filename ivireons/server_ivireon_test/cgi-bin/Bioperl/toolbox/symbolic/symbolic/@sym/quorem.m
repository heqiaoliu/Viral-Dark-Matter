function [Q,R] = quorem(A,B,x)
%QUOREM Symbolic matrix element-wise quotient and remainder.
%   [Q,R] = QUOREM(A,B) for symbolic matrices A and B with integer or
%   polynomial elements does element-wise division of A by B and returns 
%   quotient Q and remainder R so that A = Q.*B+R.
%   For polynomials, QUOREM(A,B,x) uses variable x instead of symvar(A,1)
%   or symvar(B,1).
%
%   Example:
%      syms x
%      p = x^3-2*x+5
%      [q,r] = quorem(x^5,p)
%         q = x^2 + 2
%         r = 4*x - 5*x^2 - 10
%      [q,r] = quorem(10^5,subs(p,'10'))
%         q = 101
%         r = 515
%
%   See also SYM/MOD, SYM/RDIVIDE, SYM/LDIVIDE.

%   Copyright 1993-2010 The MathWorks, Inc.

if ~isa(A,'sym'), A = sym(A); end
if ~isa(B,'sym'), B = sym(B); end
if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
if builtin('numel',B) ~= 1,  B = normalizesym(B);  end

if isa(A.s,'maplesym')
    if nargin < 3
        [Q,R] = quorem(A.s,B.s);
    else
        if isa(x,'sym')
            x = x.s;
        end
        [Q,R] = quorem(A.s,B.s,x);
    end
    Q = sym(Q);
    R = sym(R);
    return;
end

if nargin < 3
   x = symvar(A,1);
   if isempty(x)
      x = symvar(B,1);
   end
end
if isempty(x)
    [Q,R] = mupadmexnout('symobj::quoremInt',A,B);
else
    if ischar(x), x = sym(x); end
    [Q,R] = mupadmexnout('symobj::quoremPoly',A,B,x);
end
