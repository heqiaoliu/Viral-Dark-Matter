function v = findsym(S,n)
%FINDSYM Finds the symbolic variables in a symbolic expression or matrix.
%   FINDSYM(S), where S is a scalar or matrix sym, returns a string 
%   containing all of the symbolic variables appearing in S. The 
%   variables are returned in lexicographical order and are separated by
%   commas. If no symbolic variables are found, FINDSYM returns the
%   empty string.  The constants pi, i and j are not considered variables.
%
%   FINDSYM(S,N) returns the N symbolic variables closest to 'x' or 'X'. 
%   Upper-case variables are returned ahead of lower-case variables.
%
%   Examples:
%      findsym(alpha+a+b) returns
%       a, alpha, b
%
%      findsym(cos(alpha)*b*x1 + 14*y,2) returns
%       x1,y
%
%      findsym(y*(4+3*i) + 6*j) returns
%       y

%   Copyright 1993-2010 The MathWorks, Inc.

if builtin('numel',S) ~= 1,  S = normalizesym(S);  end
if isa(S.s,'maplesym')
    if nargin == 2
        v = findsym(S.s,n);
    else
        v = findsym(S.s);
    end
    if isa(v,'maplesym')
        v = sym(v);
    end
else
    if nargin == 2
        v = mupadmex('symobj::findsym', S.s, num2str(n), 0);
    else
        v = mupadmex('symobj::findsym', S.s, 0);
    end
    v = strrep(v,'_Var','');
    v(v==' ')=[];
    v = v(2:end-1); % trim quotes from around output
end
