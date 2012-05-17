function str = callback2string(callback)
; %#ok Undocumented
% Matlab callbacks are passed to us as a function name, a function handle, an
% anonymous function or a cell array.  We only support a restricted form of cell
% arrays that can be displayed in a single line.

%   Copyright 2007-2008 The MathWorks, Inc.
    
if ischar(callback)
    str = callback;
    return;
end

if isa(callback, 'function_handle')
    str = iFcn2string(callback);
    return;
end

if iscell(callback)
    str = iCell2string(callback);
    return;
end

error('distcomp:typechecker:invalidInput', ...
      'Invalid callback of type %s.', class(callback));

function str = iFcn2string(callback)
    str = func2str(callback);
    % Add a @ if the function name isn't an anonymous function which
    % already has the @ inserted by func2str
    if ~isempty(str) && str(1) ~= '@'
        str = [ '@' str ]; 
    end

function str = iCell2string(callback)
str = '{';
for i = 1:length(callback)
    curr = callback{i};
    if ndims(curr) > 2 
        error('distcomp:typechecker:unsupportedMatrix', ...
              'Cannot display arrays of dimension greater than 2.');
    end
    if size(curr, 1) > 1 || size(curr, 2) > 100
        error('distcomp:typechecker:unsupportedMatrix', ...
              'Cannot display arrays which contain more than 1 row or 100 columns.');
    end
    if ischar(curr)
        % Double all the quotes in curr so that quotes in curr are converted into quotes
        % as displayed inside of strings.
        q = '''';
        curr = strrep(curr, q, [q q]);
        str = [str, q, curr, q]; %#ok<AGROW>
    elseif isnumeric(curr) || islogical(curr)
        % Use sprintf to get the correct on-screen representation that is
        % independent of the user's format settings.
        currStr = sprintf('%g ', curr);
        if numel(curr) > 1
            str = [str, '[', currStr, ']',  ]; %#ok<AGROW>
        else
            str = [str, currStr]; %#ok<AGROW>
        end
    elseif isa(curr, 'function_handle')
        str = [str, iFcn2string(curr)]; %#ok<AGROW>
    else
        error('distcomp:typechecker:unsupportedCallback', ...
              'The class %s is not supported inside a cell array callback', ...
              class(curr));
    end
    if i < length(callback)
        str = [str, ', ']; %#ok<AGROW>
    end
end
str = [str, '}'];

