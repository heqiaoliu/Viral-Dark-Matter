function a = setlabels(a,newlabels,levels)
%SETLABELS Relabel levels for a categorical array.
%   B = SETLABELS(A,NEWLABELS) relabels the levels of the categorical array A.
%   NEWLABELS is a cell array of strings or a 2-dimensional character matrix.
%   Labels are assigned to levels in the order supplied in NEWLABELS.
%
%   B = SETLABELS(A,NEWLABELS,LEVELS) relabels only the levels specified in
%   LEVELS.  LEVELS is a cell array of strings or a 2-dimensional character
%   matrix.
%
%   See also CATEGORICAL/GETLABELS.

%   Copyright 2006-2007 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:19 $

newlabels = categorical.checklabels(newlabels,2); % error if duplicates

if nargin < 3
    if length(newlabels) ~= length(a.labels)
        error('stats:categorical:setlabels:SizeMismatch', ...
              'NEWLABELS must have the same number of elements as the number of existing categorical levels.');
    end
    a.labels = newlabels;
else
    levels = categorical.checklabels(levels,2); % error if duplicates
    if length(newlabels) ~= length(levels)
        error('stats:categorical:setlabels:SizeMismatch', ...
              'NEWLABELS and LEVELS must be the same length.');
    end
    [tf,locs] = ismember(levels,a.labels);
    if ~all(tf)
        error('stats:categorical:setlabels:InvalidLevels', ...
              'LEVELS must be a subset of the existing categorical levels.');
    end
    a.labels(locs) = newlabels;
end
