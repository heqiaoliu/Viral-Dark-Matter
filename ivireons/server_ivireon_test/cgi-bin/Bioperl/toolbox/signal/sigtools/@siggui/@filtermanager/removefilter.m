function removefilter(this, indx)
%REMOVEFILTER   Remove a filter from the manager.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/05/23 08:16:54 $

if nargin < 2
    indx = this.SelectedFilters;
end

if max(indx) > length(this.Data)
    error(generatemsgid('IdxOutOfBound'),'Index exceeds filters.');
end

% Remove the filters from the end forward, since each removal will affect
% the next.
indx = sort(unique(indx(:)'), 'descend');

sf = get(this, 'SelectedFilters');

for jndx = 1:length(indx)
    this.Data.removeelementat(indx(jndx));
    
    % Remove the index from selected filters.
    findx = find(sf == indx(jndx));
    if ~isempty(findx)
        sf(findx) = [];
    end
    
    % Change all the indexes greater than the index.
    findx = find(sf > indx(jndx));
    sf(findx) = sf(findx)-1;
end

this.SelectedFilters = sf;

if this.Data.length == 0
    this.Overwrite = 'off';
end

send(this, 'NewData');

% [EOF]
