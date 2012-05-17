function pVerifyClassName(name)
;%#ok Undocumented
%Throw an error if name is clearly an invalid name of a class or a function.

% Copyright 2007 The MathWorks, Inc.


if ~(ischar(name) && length(name) == size(name, 2) ...
    && ~isempty(name))
    error('distcomp:configpropstorage:InvalidClassName', ...
          ['Invalid input of type ''%s''.\n', ...
           'The class name/function name must be specified as a ', ...
           'non-empty string.'], class(name))
end
