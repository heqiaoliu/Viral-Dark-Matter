function r = symsum(f,x,a,b)
%SYMSUM Symbolic summation.
%   SYMSUM(S) is the indefinite summation of S with respect to the
%   symbolic variable determined by SYMVAR.
%   SYMSUM(S,v) is the indefinite summation with respect to v.
%   SYMSUM(S,a,b) and SYMSUM(S,v,a,b) are the definite summation from a to b.
%
%   Examples:
%      symsum(k)                     k^2/2 - k/2
%      symsum(k,0,n-1)               (n*(n - 1))/2
%      symsum(k,0,n)                 (n*(n + 1))/2
%      simple(symsum(k^2,0,n))       n^3/3 + n^2/2 + n/6
%      symsum(k^2,0,10)              385
%      symsum(k^2,11,10)             0
%      symsum(1/k^2)                 -psi(k, 1)
%      symsum(1/k^2,1,Inf)           pi^2/6
%
%   See also SYM/INT.

%   Copyright 1993-2010 The MathWorks, Inc.

if ~isa(f,'sym'), f = sym(f); end
if builtin('numel',f) ~= 1,  f = normalizesym(f);  end
if isa(f.s,'maplesym')
    if nargin == 1
        r = symsum(f.s);
    elseif nargin == 2
        f = sym(f);
        x = sym(x);
        r = symsum(f.s,x.s);
    elseif nargin == 3
        f = sym(f);
        x = sym(x);
        a = sym(a);
        r = symsum(f.s,x.s,a.s);
    else
        f = sym(f);
        x = sym(x);
        a = sym(a);
        b = sym(b);
        r = symsum(f.s,x.s,a.s,b.s);
    end
    r = sym(r);
    return;
end

if nargin == 1
   x = symvar(f,1);
end
if nargin <= 2
   % Indefinite summation
   if ischar(x), x = sym(x); end
   if builtin('numel',x) ~= 1,  x = normalizesym(x);  end
   r = mupadmex('symobj::map',f.s,'sum',x.s);

else
   % Definite summation
   if nargin == 3
      b = a;
      a = x;
      x = symvar(f,1);
      if isempty(x), x = sym('x'); end
   end
   if ischar(x), x = sym(x); end
   if builtin('numel',x) ~= 1,  x = normalizesym(x);  end
   if isnumeric(a) && isnumeric(b) && a > b
       r = repmat(sym(0),size(f));
       return;
   end
   if ~isa(a,'sym'), a = sym(a); end
   if ~isa(b,'sym'), b = sym(b); end
   if builtin('numel',a) ~= 1,  a = normalizesym(a);  end
   if builtin('numel',b) ~= 1,  b = normalizesym(b);  end
   r = mupadmex('symobj::map',f.s,'symobj::symsum',x.s,a.s,b.s);
end
