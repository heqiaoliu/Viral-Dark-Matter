function a = mergelevels(a,oldlevels,newlevel)
%MERGELEVELS Merge levels of an ordinal array.
%   B = MERGELEVELS(A,OLDLEVELS,NEWLEVEL) merges two or more levels of the
%   ordinal array A into a single new level.  OLDLEVELS is a cell array of
%   strings or a 2-dimensional character matrix that specifies the levels to
%   be merged.  The levels of A specified by OLDLEVELS must be consecutive,
%   and MERGELEVELS inserts the new level to preserve the order of levels.
%   Any elements of A that have levels in OLDLEVELS are assigned the new level
%   in the corresponding elements of B.  NEWLEVEL is a character string that
%   specifies the label for the new level.
%
%   B = MERGELEVELS(A,OLDLEVELS) merges two or more levels of A and uses the
%   label corresponding to the lowest level in OLDLEVELS as the label for the
%   new level.
%
%   See also ORDINAL/ADDLEVELS, ORDINAL/DROPLEVELS, ORDINAL/ISLEVEL,
%            ORDINAL/REORDERLEVELS, ORDINAL/GETLABELS.

%   Copyright 2006-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:38:47 $

oldlevels = categorical.checklabels(oldlevels,1); % warn and remove if duplicates

% Find the codes for the levels that will be merged.
[tf,oldcodes] = ismember(oldlevels,a.labels);

% Ignore anything in oldlevels that didn't match a level of A.
if any(oldcodes == 0)
    warning('stats:ordinal:mergelevels:UnusedOldLevels', ...
            'Ignoring elements of OLDLEVELS that are not existing categorical levels.')
    oldcodes(oldcodes == 0) = [];
end

% Cannot merge nonconsecutive levels.
if ~all(tf) || any(diff(sort(oldcodes))~=1)
    error('stats:ordinal:mergelevels:NonconsecutiveLevels', ...
          'Cannot merge nonconsecutive levels for an ordinal object.');
end

if nargin < 3
    newlevel = a.labels{min(oldcodes)}; % use the lowest level's label
else
    if ischar(newlevel) && (size(newlevel,1)==1) && (ndims(newlevel) == 2)
        newlevel = strtrim(newlevel);
        if strcmp(categorical.undefLabel,newlevel)
            error('stats:categorical:mergelevels:UndefinedLabel', ...
                  'NEWLEVEL may not be the string ''%s''.',categorical.undefLabel);
        elseif isempty(newlevel)
            error('stats:categorical:mergelevels:InvalidNewLevel', ...
                  'NEWLEVEL may not be the empty string.');
        end
    else
        error('stats:categorical:mergelevels:InvalidNewLevel', ...
              'NEWLEVEL must be a character string.');
    end
end

convert = 1:length(a.labels);

% The new level will be the lowest of the old levels.  Remove the remaining old
% levels from A, and add the label for the new level (it may be an old one).
[newcode,j] = min(oldcodes); oldcodes(j) = [];
a.labels(oldcodes) = [];
a.labels{newcode} = newlevel;

% Merge the codes for the old levels to the new level.
offset = zeros(size(convert));
offset(oldcodes) = 1; 
convert = convert - cumsum(offset);
convert(oldcodes) = newcode;
convert = cast([0 convert],class(a.codes)); % there may be zeros in a.codes
a.codes = reshape(convert(a.codes+1),size(a.codes));
