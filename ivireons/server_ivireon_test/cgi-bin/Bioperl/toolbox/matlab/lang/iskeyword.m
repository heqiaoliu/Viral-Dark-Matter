function L = iskeyword(s)
%ISKEYWORD Check if input is a keyword.
%   ISKEYWORD(S) returns one if S is a MATLAB keyword,
%   and 0 otherwise.  MATLAB keywords cannot be used 
%   as variable names.
%
%   ISKEYWORD used without any inputs returns a cell array containing
%   the MATLAB keywords.
%
%   See also ISVARNAME, GENVARNAME.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.3.4.4 $  $Date: 2008/06/24 17:13:58 $

L = {...
    'break'
    'case'
    'catch'
    'classdef'
    'continue'
    'else'
    'elseif'
    'end'
    'for'
    'function'
    'global'
    'if'
    'otherwise'
    'parfor'
    'persistent'
    'return'
    'spmd'
    'switch'
    'try'
    'while'
    };

if nargin==0
%  Return the list only
  return
else
  L = any(strcmp(s,L));
end
