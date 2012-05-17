function a = setobsnames(a,newnames,obs)
%SETOBSNAMES Set dataset array observation names.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:36 $

if nargin < 2
    error('stats:dataset:setobsnames:TooFewInputs', ...
          'Requires at least two inputs.');
end

if nargin == 2
    if isempty(newnames)
        a.obsnames = {}; % do this for cosmetics
        return
    end
    if isstring(newnames)
        if a.nobs ~= 1
            error('stats:dataset:setobsnames:IncorrectNumberOfObsnames', ...
                  'NEWNAMES must contain one name for each each observation in A.');
        end
        newnames = cellstr(newnames);
    elseif iscell(newnames)
        if numel(newnames) ~= a.nobs
            error('stats:dataset:setobsnames:IncorrectNumberOfObsnames', ...
                  'NEWNAMES must contain one name for each observation in A.');
        elseif ~all(cellfun(@isstring,newnames))
            error('stats:dataset:setobsnames:InvalidObsnames', ...
                  'NEWNAMES must be a nonempty string or a cell array of nonempty strings.');
        elseif checkduplicatenames(newnames);
            error('stats:dataset:setobsnames:DuplicateObsnames', ...
                  'Duplicate observation names.');
        end
    else
        error('stats:dataset:setobsnames:InvalidObsnames', ...
              'NEWNAMES must be a nonempty string or a cell array of nonempty strings.');
    end
    a.obsnames = strtrim(newnames(:));
    
elseif isempty(a.obsnames)
    error('stats:dataset:setobsnames:InvalidPartialAssignment', ...
          'Must assign all observation names when the ''ObsNames'' property is empty.');
    
else % if nargin == 3
    obsIndices = getobsindices(a,obs)
    if isstring(newnames)
        if a.nobs ~= 1
            error('stats:dataset:setobsnames:IncorrectNumberOfObsnames', ...
                  'NEWNAMES must contain one name for each observation in A.');
        end
        newnames = cellstr(newnames);
    elseif iscell(newnames)
        if ~all(cellfun(@isstring,newnames))
            error('stats:dataset:setobsnames:InvalidObsnames', ...
                  'NEWNAMES must be a string or a cell array of nonempty strings.');
        elseif length(newnames) ~= length(obsIndices)
            error('stats:dataset:setobsnames:IncorrectNumberOfObsnames', ...
                  'NEWNAMES must contain one name for each observation name being replaced.');
        end
    else
        error('stats:dataset:setobsnames:InvalidObsnames', ...
              'NEWNAMES must be a string or a cell array of nonempty strings.');
    end
    if checkduplicatenames(newnames,a.obsnames,obsIndices);
        error('stats:dataset:setobsnames:DuplicateObsnames', ...
              'Duplicate observation names.');
    end
    a.obsnames(obsIndices) = strtrim(newnames);
end

% We've already errored out on duplicate obs names, so there's no need to uniqueify.

    
function tf = isstring(s) % require a nonempty row of chars
tf = ischar(s) && isvector(s) && (size(s,1) == 1) && ~isempty(s);
