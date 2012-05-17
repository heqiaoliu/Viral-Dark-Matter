function a = addlevels(a,newlevels)
%ADDLEVELS Add levels to a categorical array.
%   B = ADDLEVELS(A,NEWLEVELS) adds levels to the categorical array A.
%   NEWLEVELS is a cell array of strings or a 2-dimensional character matrix
%   that specifies levels to be added.  ADDLEVELS adds the new levels at the
%   end of A's list of possible categorical levels.
%
%   ADDLEVELS adds new levels, but does not modify the value of any elements.
%   B will not contain any elements that actually have those new levels as
%   their value until you assign those levels to some of its elements.
%
%   See also CATEGORICAL/DROPLEVELS, CATEGORICAL/ISLEVEL, CATEGORICAL/MERGELEVELS,
%            CATEGORICAL/REORDERLEVELS, CATEGORICAL/GETLABELS.

%   Copyright 2006-2007 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:36:35 $

% Don't check for duplicate labels here, since we have to do it across
% existing and new labels anyway
newlevels = categorical.checklabels(newlevels,0);

if length(newlevels)+length(a.labels) > categorical.maxCode
    error('stats:categorical:categorical:MaxNumLevelsExceeded', ...
          'Too many categorical levels.');
end

% Tack the new levels onto the end of existing list.  Removing any duplicates,
% either within the new labels, or between the existing labels and the new
% ones, but leave everything in original order.
newlevels = [a.labels newlevels];
if length(newlevels) > 1
    [sortedlevels,ord] = sort(newlevels);
    d = [true ~strcmp(sortedlevels(2:end),sortedlevels(1:end-1))];
    if ~all(d)
        warning('stats:categorical:addlevels:DuplicateLevelsIgnored', ...
                'Ignoring duplicate levels in NEWLEVELS.');
        newlevels = newlevels(sort(ord(d)));
    end
end
a.labels = newlevels;
