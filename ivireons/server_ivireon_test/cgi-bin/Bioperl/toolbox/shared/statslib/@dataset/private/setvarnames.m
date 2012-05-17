function a = setvarnames(a,newnames,vars,allowMods)
%SETVARNAMES Set dataset array variable names.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:38 $

if nargin < 2
    error('stats:dataset:setvarnames:TooFewInputs', ...
          'Requires at least two inputs.');
elseif nargin < 4
    allowMods = true;
end

if nargin == 2 || isempty(vars)
    if isstring(newnames)
        if a.nvars ~= 1
            error('stats:dataset:setvarnames:IncorrectNumberOfVarnames', ...
                  'NEWNAMES must contain one name for each variable in A.');
        end
        newnames = cellstr(newnames);
    elseif iscell(newnames)
        if numel(newnames) ~= a.nvars
            error('stats:dataset:setvarnames:IncorrectNumberOfVarnames', ...
                  'NEWNAMES must have one name for each variable in A.');
        elseif ~all(cellfun(@isstring,newnames)) % require a nonempty row of chars
            error('stats:dataset:setvarnames:InvalidVarnames', ...
                  'NEWNAMES must be a nonempty string or a cell array of nonempty strings.');
        end
    elseif ~iscell(newnames)
        error('stats:dataset:setvarnames:InvalidVarnames', ...
              'NEWNAMES must be a nonempty string or a cell array of nonempty strings.');
    end
    newnames = strtrim(newnames(:))'; % this conveniently converts {} to a 1x0
    [newnames,wereModified] = genvalidnames(newnames,allowMods); % will warn if mods are made
    if checkduplicatenames(newnames);
        error('stats:dataset:setvarnames:DuplicateVarnames', ...
              'Duplicate variable names.');
    end
    checkreservednames(newnames);
    a.varnames = newnames;
    
else % if nargin == 3
    varIndices = getvarindices(a,vars);
    if isstring(newnames)
        if ~isscalar(varIndices)
            error('stats:dataset:setvarnames:IncorrectNumberOfVarnames', ...
                  'NEWNAMES must contain one name for each variable name being replaced.');
        end
        newnames = cellstr(newnames);
    elseif iscell(newnames)
        if length(newnames) ~= length(varIndices)
            error('stats:dataset:setvarnames:IncorrectNumberOfVarnames', ...
                  'NEWNAMES must contain one name for each variable name being replaced.');
        elseif ~all(cellfun(@isstring,newnames)) % require a nonempty row of chars
            error('stats:dataset:setvarnames:InvalidVarnames', ...
                  'NEWNAMES must be a nonempty string or a cell array of nonempty strings.');
        end
    else
        error('stats:dataset:setvarnames:InvalidVarnames', ...
              'NEWNAMES must be a nonempty string or a cell array of nonempty strings.');
    end
    newnames = strtrim(newnames);
    [newnames,wereModified] = genvalidnames(newnames,allowMods); % will warn if mods are made
    if checkduplicatenames(newnames) || checkduplicatenames(newnames,a.varnames,varIndices);
        error('stats:dataset:setvarnames:DuplicateVarnames', ...
              'Duplicate variable names.');
    end
    checkreservednames(newnames);
    a.varnames(varIndices) = newnames;
end


function tf = isstring(s) % require a nonempty row of chars
tf = ischar(s) && isvector(s) && (size(s,1) == 1) && ~isempty(s);
