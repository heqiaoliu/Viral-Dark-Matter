function [r,h] = simple(s)
%SIMPLE Search for simplest form of a symbolic expression or matrix.
%   SIMPLE(S) tries several different algebraic simplifications of
%   S, displays any which shorten the length of S's representation,
%   and returns the shortest. S is a SYM. If S is a matrix, the result
%   represents the shortest representation of the entire matrix, which is 
%   not necessarily the shortest representation of each individual element.
%
%   [R,HOW] = SIMPLE(S) does not display intermediate simplifications,
%   but returns the shortest found, as well as a string describing
%   the particular simplification. R is a SYM. HOW is a string.
%
%   Examples:
%
%      S                          R                  How
%
%      cos(x)^2+sin(x)^2          1                  simplify
%      2*cos(x)^2-sin(x)^2        3*cos(x)^2-1       simplify
%      cos(x)^2-sin(x)^2          cos(2*x)           simplify
%      cos(x)+i*sin(x)            exp(i*x)           rewrite(exp)
%      (x+1)*x*(x-1)              x^3-x              simplify(100)
%      x^3+3*x^2+3*x+1            (x+1)^3            simplify
%      cos(3*acos(x))             4*x^3-3*x          simplify(100)
%
%   See also SYM/SIMPLIFY, SYM/FACTOR, SYM/EXPAND, SYM/COLLECT.

%   Copyright 1993-2010 The MathWorks, Inc.

if builtin('numel',s) ~= 1,  s = normalizesym(s);  end
if isa(s.s,'maplesym')
    [r,h] = simple(s.s);
    r = sym(r);
    h = char(h);
else
    p = nargout == 0;
    [r,h] = mupadSimple(s,p);
end
end

function [r,h] = mupadSimple(s,p)
    h = '';
    r = s;
    x = symvar(s,1);

    % Try the different simplifications.
    [r,h] = simpler('simplify',s,r,h,p);
    [r,h] = simpler('radsimp',s,r,h,p);

    [r,h] = simpler('symobj::simplify',s,r,h,p,'100');
    [r,h] = simpler('combine',s,r,h,p,'sincos');
    [r,h] = simpler('combine',s,r,h,p,'sinhcosh');
    [r,h] = simpler('combine',s,r,h,p,'ln');

    [r,h] = simpler('factor',s,r,h,p);
    [r,h] = simpler('expand',s,r,h,p);
    [r,h] = simpler('combine',s,r,h,p);

    [r,h] = simpler('rewrite',s,r,h,p,'exp');
    [r,h] = simpler('rewrite',s,r,h,p,'sincos');
    [r,h] = simpler('rewrite',s,r,h,p,'sinhcosh');
    [r,h] = simpler('rewrite',s,r,h,p,'tan');
    [r,h] = simpler('symobj::mwcos2sin',s,r,h,p);

    if ~isempty(x)
        [r,h] = simpler('collect',s,r,h,p,x);
    end
end

function [r,h] = simpler(how,s,r,h,p,x)
%SIMPLER Used by SIMPLE to shorten expressions.
%   SIMPLER(HOW,S,R,H,P,X) applies method HOW with optional parameter X
%   to expression S, prints the result if P is nonzero, compares the
%   length of the result with expression R, which was obtained with
%   method H, and returns the shortest string and corresponding method.

if nargin < 6
    [t,err] = mupadmex('symobj::map',s.s,how);
elseif ischar(x)
    [t,err] = mupadmex('symobj::map',s.s,how,x);
else
    [t,err] = mupadmex('symobj::map',s.s,how,x.s);
end

if err
    return;
end

if nargin == 6
   how = [how '(' char(x) ')'];
end

how = strrep(how,'symobj::','');

if p 
   loose = isequal(get(0,'FormatSpacing'),'loose');
   if loose, disp(' '), end
   disp([how ':'])
   if loose, disp(' '), end
   disp(t)
end

cmp = mupadmex('symobj::simpler', t.s, r.s, 0);
if strcmp(cmp,'TRUE') 
   r = t;
   h = how;
end
end
