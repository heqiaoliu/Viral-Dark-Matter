function s = eval(x)
%EVAL  Evaluate a symbolic expression.
%   EVAL(S) evaluates the character representation of the
%   symbolic expression S in the caller's workspace.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/16 00:42:05 $

if builtin('numel',x) ~= 1,  x = normalizesym(x);  end
if isa(x.s,'maplesym')
    w = sym2str(x.s);
    cmd = sprintf('symengine(''evalincaller'',''%s'')',w);
    s = evalin('caller',cmd);
else
    s = evalin('caller',vectorize(map2mat(char(x))));
end

%-------------------------

function r = map2mat(r)
% MAP2MAT Maple to MATLAB string conversion.
%   MAP2MAT(r) converts the Maple string r containing
%   matrix, vector, or array to a valid MATLAB string.
%
%   Examples: map2mat(matrix([[a,b], [c,d]])  returns
%             [a,b;c,d]
%             map2mat(array([[a,b], [c,d]])  returns
%             [a,b;c,d]
%             map2mat(vector([[a,b,c,d]])  returns
%             [a,b,c,d]

% Deblank.
r(findstr(r,' ')) = [];
% Remove matrix, vector, or array from the string.
r = strrep(r,'matrix([[','['); r = strrep(r,'array([[','[');
r = strrep(r,'vector([','['); r = strrep(r,'],[',';');
r = strrep(r,']])',']'); r = strrep(r,'])',']');
% Special case of the empty matrix or vector
if strcmp(r,'vector([])') || strcmp(r,'matrix([])') || ...
   strcmp(r,'array([])')
r = [];
end
