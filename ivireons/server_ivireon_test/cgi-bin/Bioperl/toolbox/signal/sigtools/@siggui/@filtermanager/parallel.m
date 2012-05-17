function parallel(this, indx)
%PARALLEL   Create a parallel filter.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:18:35 $

if nargin < 2
    indx = this.SelectedFilters;
end

if max(indx) > length(this.Filters)
    error(generatemsgid('IdxOutOfBound'),'Index exceeds filters.');
end

newfilt = parallel(this.Filters(indx));
newsrc  = 'Filter Manager';
newfs   = 1;

% names = this.Names(indx);
newname = sprintf('Parallel of %s', sprintf('%s, ', this.Name{indx}));
newname(end-1:end) = [];

% We need to make sure that this thing is as short as possible.
if length(newname) > 30
    newname = [newname(1:27) '...'];
end

this.addfilter(newfilt, newname, newfs, newsrc);

% Set the current filter to be the new filter.
this.CurrentFilter = length(this.Filters);
set(this, 'SelectedFilters', length(this.Data));

% [EOF]
