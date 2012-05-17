function a = droplevels(a,oldlevels)
%DROPLEVELS Remove levels from a categorical array.
%   B = DROPLEVELS(A) removes unused levels from the categorical array A.  B
%   is a categorical array with the same size and values as A, but whose list
%   of potential levels includes only those levels of A that are actually
%   present in some element of A.
%
%   B = DROPLEVELS(A,OLDLEVELS) removes levels from the categorical array A.
%   OLDLEVELS is a cell array of strings or a 2-dimensional character matrix
%   that specifies the levels to be removed.
%
%   DROPLEVELS removes levels, but does not remove elements.  Elements of B
%   that correspond to elements of A having levels in OLDLEVELS are all
%   assigned the undefined level.
%
%   See also CATEGORICAL/ADDLEVELS, CATEGORICAL/ISLEVEL, CATEGORICAL/MERGELEVELS,
%            CATEGORICAL/REORDERLEVELS, CATEGORICAL/GETLABELS.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/10/10 20:10:50 $

if nargin < 2
    % Find any unused codes in A.
    codehist = histc(a.codes(:),1:length(a.labels));
    oldcodes = find(codehist == 0);
else
    oldlevels = categorical.checklabels(oldlevels,1); % warn and remove if duplicates
    
    % Find the codes for the levels that will be dropped.
    oldcodes = zeros(1,length(oldlevels));
    elementsUndefined = false;
    for i = 1:length(oldlevels)
        found = find(strcmp(oldlevels{i},a.labels));
        if ~isempty(found) % a unique match
            oldcodes(i) = found;
            if any(a.codes(:) == found)
                elementsUndefined = true;
            end
        else % no match
%             oldcodes(i) = 0;
        end
    end
    
    % Ignore anything in oldlevels that didn't match a level of A.
    if any(oldcodes == 0)
        warning('stats:categorical:addlevels:OldLevelsNotPresent', ...
                'Ignoring elements of OLDLEVELS that are not existing categorical levels.')
        oldcodes(oldcodes == 0) = [];
    end
    
    % Warn if any elements of A will become undefined.
    if elementsUndefined
        warning('stats:categorical:addlevels:UndefinedLevelAssigned', ...
                ['OLDLEVELS contains categorical levels that were present in the input ' ...
                 'array A.  As a result, the output array B contains array elements ' ...
                 'that have undefined levels.']);

    end
end

convert = 1:length(a.labels);

% Remove the old levels from A.
a.labels(oldcodes) = [];

% Translate the codes for the levels that haven't been dropped.
dropped = zeros(size(convert));
dropped(oldcodes) = 1; 
convert = convert - cumsum(dropped);
convert(dropped>0) = 0;
convert = cast([0 convert],class(a.codes)); % there may be zeros in a.codes
a.codes = reshape(convert(a.codes+1),size(a.codes));
