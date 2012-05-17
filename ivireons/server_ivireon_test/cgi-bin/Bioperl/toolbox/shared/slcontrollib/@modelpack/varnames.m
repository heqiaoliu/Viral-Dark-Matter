function [names, subs] = varnames(strs, delimiters)
% VARNAMES Extracts the variable names from the strings.
%
% STRS is either a string or a cell array of strings.
% DELIMITERS is an (optional) array of delimiter characters.
%
% NAMES is a string or a cell array of strings containing variable names.
% SUBS  is a string or a cell array of strings containing subscripts.
%
% K(i), S.a, C{j}, ... => names: K, S, C, ...
%                      => subs : (i), .a, {j}, ...

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:56:05 $

% Default arguments
if (nargin < 2 || isempty(delimiters)), delimiters = '.({'; end

% Tokenize the string(s).
[names, subs] = strtok(strs, delimiters);
