function cascade(this, indx)
%CASCADE   Cascade multiple filters.
%   CASCADE(THIS, INDX)   Cascade the filters at the indices specified in
%   INDX.  They will have Fs = to the lowest Fs of all the filters.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/14 15:18:34 $

if nargin < 2
    indx = this.SelectedFilters;
end

if max(indx) > length(this.Data)
    error(generatemsgid('IdxOutOfBound'),'Index exceeds filters.');
end

filts = getfilters(this, indx);

fs = get(filts, 'Fs');
newfs = max([fs{:}]);

filts = get(filts, 'Filter');

newfilt = cascade(filts{:});
newsrc  = 'Filter Manager';

% names = this.Names(indx);
names = getnames(this, indx);
newname = sprintf('Cascade of %s', sprintf('%s, ', names{:}));
newname(end-1:end) = [];

% We need to make sure that this thing is as short as possible.
if length(newname) > 60
    newname = [newname(1:57) '...'];
end

% Add this filter and make it the selected.
this.addfilter(newfilt, newname, newfs, newsrc);
set(this, 'SelectedFilters', length(this.Data));

% [EOF]
