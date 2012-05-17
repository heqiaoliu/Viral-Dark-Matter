function a = mergelevels(a,oldlevels,newlevel)
%MERGELEVELS Merge levels of a nominal array.
%   B = MERGELEVELS(A,OLDLEVELS,NEWLEVEL) merges two or more levels of the
%   nominal array A into a single new level.  OLDLEVELS is a cell array of
%   strings or a 2-dimensional character matrix that specifies the levels to
%   be merged.  Any elements of A that have levels in OLDLEVELS are assigned
%   the new level in the corresponding elements of B.  NEWLEVEL is a character
%   string that specifies the label for the new level.
%
%   B = MERGELEVELS(A,OLDLEVELS) merges two or more levels of A and uses the
%   first label in OLDLEVELS as the label for the new level.
%
%   See also NOMINAL/ADDLEVELS, NOMINAL/DROPLEVELS, NOMINAL/ISLEVEL,
%            NOMINAL/REORDERLEVELS, NOMINAL/GETLABELS.

%   Copyright 2006-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:38:26 $

oldlevels = categorical.checklabels(oldlevels,1); % warn and remove if duplicates

% Find the codes for the levels that will be merged.
[tf,oldcodes] = ismember(oldlevels,a.labels);

% Ignore anything in oldlevels that didn't match a level of A.
if any(oldcodes == 0)
    warning('stats:nominal:mergelevels:UnusedOldLevels', ...
            'Ignoring elements of OLDLEVELS that are not existing categorical levels.')
    oldcodes(oldcodes == 0) = [];
end

if nargin < 3
    newlevel = oldlevels{1};
else
    if ischar(newlevel) && (size(newlevel,1)==1) && (ndims(newlevel) == 2)
        newlevel = strtrim(newlevel);
        if strcmp(categorical.undefLabel,newlevel)
            error('stats:nominal:mergelevels:UndefinedLabel', ...
                  'NEWLEVEL may not be the string ''%s''.',categorical.undefLabel);
        elseif isempty(newlevel)
            error('stats:nominal:mergelevels:InvalidNewLevel', ...
                  'NEWLEVEL may not be the empty string.');
        end
    else
        error('stats:nominal:mergelevels:InvalidNewLevel', ...
              'NEWLEVEL must be a character string.');
    end
end

convert = 1:length(a.labels);

% Remove the old levels from A, and add the new level.
a.labels(oldcodes) = [];
newcode = length(a.labels) + 1;
a.labels{newcode} = newlevel;

% Merge the codes for the old levels to the new level.
offset = zeros(size(convert));
offset(oldcodes) = 1;
convert = convert - cumsum(offset);
convert(oldcodes) = newcode;
convert = cast([0 convert],class(a.codes)); % there may be zeros in a.codes
a.codes = reshape(convert(a.codes+1),size(a.codes));
