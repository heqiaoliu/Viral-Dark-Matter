function callback = string2callback(str)
; %#ok Undocumented
% Matlab callbacks are passed to us as strings.  Must be as a function name, a
% function handle, an anonymous function or a cell array.  We only support cell
% arrays that we know we can convert back to strings.

%   Copyright 2007-2008 The MathWorks, Inc.

if isa(str, 'java.lang.String')
    str = char(str);
end
if ~ischar(str)
    error('distcomp:typechecker:invalidCallback', ...
          'Invalid input.  Expected a string, but received %s.', class(str));
end
if ndims(str) > 2 || size(str, 1) > 1
    error('distcomp:typechecker:invalidCallback', ...
          'Invalid input.  Input string should be a row vector.');
end

str = strtrim(char(str));
if ~isempty(str) 
    switch str(1)
      case '@'
        callback = iHandleFcn(str);
      case '{'
        callback = iHandleCellArray(str);
      otherwise
        % Just a regular string that should be eval'ed.
        callback = str;
    end
end


function callback = iHandleFcn(str)
% Str is either a function handle or an anonymous function.
% In either case, we eval it to convert to a function handle.

% The following evaluation may well throw an error.  We can't use str2func
% because it only handles 'foo' --> @foo, and not '@foo' --> @foo.

try
    callback = eval(str);
catch err
    error('distcomp:typechecker:invalidCallback', ...
          ['Failed to convert the string ''%s'' to a callback function\n', ...
           'due to the following error:\n%s'], ...
          str, err.message);
end
if ~isa(callback, 'function_handle');
    error('distcomp:typechecker:invalidCallback', ...
          ['Failed to convert the string ''%s'' to a callback function because\n', ...
           'it did not evaluate to a function handle.'], str);
end


function callback = iHandleCellArray(str)
%Str is a cell array whose first elem is either a function handle or a function
%name.

% The following evaluation may well throw an error.  We pass that error
% unmodified to the caller.
try
    callback = eval(str);
catch err
    error('distcomp:typechecker:invalidCallback', ...
          ['Failed to convert the string ''%s'' to a cell array callback function\n', ...
           'due to the following error:\n%s'], ...
          str, err.message);
end

if ~iscell(callback) || isempty(callback)
    error('distcomp:typechecker:invalidCallback', ...
          ['Failed to convert the string ''%s'' to a callback function because\n', ...
           'it did not evaluate to a non-empty cell array.'], str);
end

if ~isa(callback{1}, 'function_handle') && ~isvarname(callback{1})
    error('distcomp:typechecker:invalidCallback', ...
          ['Failed to convert the string ''%s'' to a callback function because\n', ...
           'the first element of cell array did not contain a function handle\n', ...
           'or a valid function name.'], str);
end
% Need to verify that the remaining elements of the cell array are such that
% callback2string can handle them.  We do that by calling callback2string to see
% whether it errors.
distcomp.typechecker.callback2string(callback);
