function uisave(variables, filename)
%UISAVE GUI Helper function for SAVE
%   
%   UISAVE with no args prompts for file name then saves all variables from
%   workspace.
%
%   UISAVE(VARIABLES) prompts for file name then saves variables listed in
%   VARIABLES, which may be a string or cell array of strings.
%
%   UISAVE(VARIABLES, FILENAME) uses the specified file name as the default
%   instead of "matlab.mat".
%
%   Examples:
%      Example 1:
%           h = 5;
%           uisave('h');
%
%      Example 2:
%           h = 365;
%           uisave('h', 'var1');
%
%   See also SAVE, LOAD
  
% Copyright 1984-2008 The MathWorks, Inc.
% $Revision: 1.12.4.10 $  $Date: 2008/12/15 08:53:39 $

whooutput = evalin('caller','who','');
if isempty(whooutput) | (nargin > 0 & ...
    (isempty(variables) | (iscell(variables) & cellfun('isempty',variables)))) %#ok<AND2,OR2>
    errordlg('No variables to save')
    return;
end

if nargin == 0
    % no variables specified, save everything
    variables = whooutput;
else
    if ~iscellstr(variables)
        variables = cellstr(variables);
    end

    missing_variables = setdiff(variables, whooutput);
    if ~isempty(missing_variables)
        errordlg(['These variables not found:' sprintf('\n    ') sprintf('%s   ',missing_variables{:})]);
        return;
    end
end

if length(whooutput) > 1
    % saving multiple variables to ascii is not very useful
    % the file will not re-load
    filters = {'*.mat','MAT-files (*.mat)'};
else
    filters = {'*.mat','MAT-files (*.mat)'
               '*.txt','ASCII-files (*.txt)'};
end

if nargin < 2
    seed = 'matlab.mat';
else
    seed = filename;
end

% convert input string cell array into a quoted single string like this
% 'a','b','c' where a, b, and c are variable names
variables = sprintf('''%s'',',variables{:});
% trim trailing comma
variables = variables(1:end - 1);


[fn,pn,filterindex] = uiputfile(filters, sprintf('Save Workspace Variables'), seed);

if ~isequal(fn,0) % fn will be zero if user hits cancel
    % quote the variables string for eval
    fn = strrep(fullfile(pn,fn), '''', '''''');

    % don't use mat if the file ext is '.txt' and 
    useMat = true;
    if (filterindex == 2 && findstr(filters{filterindex}, '.txt'))
        useMat = false;
    end

    % do save and throw errordlg on error
    try
        if useMat
            evalin('caller',['save(''' fn  ''', ' variables ');']);
        else
            evalin('caller',['save(''' fn  ''', ' variables ', ''-ASCII'');']);
        end
    catch ex
    errordlg(ex.getReport('basic', 'hyperlinks', 'off')); 
    end
end

