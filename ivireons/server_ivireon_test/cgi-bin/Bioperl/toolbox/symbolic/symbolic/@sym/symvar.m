function v = symvar(S,n)
%SYMVAR Finds the symbolic variables in a symbolic expression or matrix.
%    SYMVAR(S), where S is a scalar or matrix sym, returns a vector sym 
%    containing all of the symbolic variables appearing in S. The 
%    variables are returned in lexicographical order. If no symbolic variables
%    are found, SYMVAR returns the empty vector. 
%    The constants pi, i and j are not considered variables.
% 
%    SYMVAR(S,N) returns the N symbolic variables closest to 'x' or 'X'. 
%    Upper-case variables are returned ahead of lower-case variables.
% 
%    Examples:
%       symvar(alpha+a+b) returns
%        [a, alpha, b]
% 
%       symvar(cos(alpha)*b*x1 + 14*y,2) returns
%        [x1, y]
% 
%       symvar(y*(4+3*i) + 6*j) returns
%        y

%   Copyright 2008-2010 The MathWorks, Inc.

if builtin('numel',S) ~= 1,  S = normalizesym(S);  end
if isa(S.s,'maplesym')
    if nargin == 2
        v = findsym(S.s,n);
    else
        v = findsym(S.s);
    end
    if isempty(strfind(v,','))
        v = sym(v);
    else
        v = sym(['[' v ']']);
    end
else
    if nargin == 2
        v = mupadmex('symobj::symvar', S.s, num2str(n));
    else
        v = mupadmex('symobj::symvar', S.s);
    end
end
