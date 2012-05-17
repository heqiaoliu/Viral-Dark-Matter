function R = diff(S,varargin)
%DIFF   Differentiate.
%   DIFF(S) differentiates a symbolic expression S with respect to its
%   free variable as determined by SYMVAR.
%   DIFF(S,'v') or DIFF(S,sym('v')) differentiates S with respect to v.
%   DIFF(S,n), for a positive integer n, differentiates S n times.
%   DIFF(S,'v',n) and DIFF(S,n,'v') are also acceptable.
%
%   Examples;
%      x = sym('x');
%      t = sym('t');
%      diff(sin(x^2)) is 2*x*cos(x^2)
%      diff(t^6,6) is 720.
%
%   See also SYM/INT, SYM/JACOBIAN, SYM/SYMVAR.

%   Copyright 1993-2010 The MathWorks, Inc.

error(nargchk(1,3,nargin,'struct'));

if ~isa(S,'sym'), S = sym(S); end
if builtin('numel',S) ~= 1,  S = normalizesym(S);  end
if isa(S.s,'maplesym')
  for k=1:length(varargin)
    x = varargin{k};
    if isa(x,'sym')
      varargin{k} = x.s;
    end
  end
  R = sym(diff(S.s,varargin{:}));
else
  n = 1;
  x = [];
  for j = 1:length(varargin)
    a = varargin{j};
    if isa(a,'sym')
      x = a;
    elseif isvarname(a)
      x = sym(a);
    elseif isa(a,'double') && length(a) == 1
      n = a;
    else
      error('symbolic:sym:diff:errmsg2','Do not recognize argument number %d.',j)
    end
  end
  if isa(x,'double')
    x = symvar(S,1);
  end
  if isempty(x)
    R = 0*S;
  elseif n == 0
    R = S;
  else
    R = mupadmex('symobj::diff', S.s, x.s, int2str(n));
  end
end
