function [X, dupesfound, idxmap] = mergeDuplicatePoints(X)
%MergeDuplicatePoints Merge out points that have coincident location.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/06/16 04:19:22 $

dupesfound = false;
numinitpoints = size(X, 1);
[~,idxmap] = unique(X,'first','rows');
numuniquepoints = length(idxmap);
if (numinitpoints > numuniquepoints)
    % Undo the sort to preserve the ordering of points
    idxmap = sort(idxmap)';
    X = X(idxmap,:);    
    dupesfound = true;
end