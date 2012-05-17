function [Y,sigma] = subexpr(X,signame)
%SUBEXPR Rewrite in terms of common subexpressions.
%   [Y,SIGMA] = SUBEXPR(X,SIGMA) or [Y,SIGMA] = SUBEXPR(X,'SIGMA')
%   rewrites the symbolic expression X in terms of its common
%   subexpressions. These are the subexpressions that are written
%   as %1, %2, etc. by PRETTY(S).
%   
%   Example:
%      t = solve('a*x^3+b*x^2+c*x+d = 0');
%      [r,s] = subexpr(t,'s');
%
%   See also SYM/PRETTY, SYM/SIMPLE, SYM/SUBS.

%   Copyright 1993-2010 The MathWorks, Inc.

% Get name of subexpression matrix
if nargin == 1
   signame = 'sigma';
elseif ~ischar(signame)
    signame = inputname(2); 
end
    
if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
if isa(X.s,'maplesym')
    [Y,sigma] = subexpr(X.s,signame);
    Y = sym(Y); sigma = sym(sigma);
else
    [Y,sigma] = mupadmexnout('symobj::subexpr',X,signame);
    if strcmp(char(sigma),'NULL')
        sigma = sym([]);
    end
end

if (nargout < 2) && ~isempty(sigma)
   assignin('caller',signame,sigma);
   loose = strcmp(get(0,'formatspacing'),'loose');
   if loose, disp(' '); end
   disp([signame,' = ']);
   if loose, disp(' '); end
   disp(sigma);
   if loose, disp(' '); end
end
