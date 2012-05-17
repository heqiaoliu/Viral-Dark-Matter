function applyFilter(this,dialog)
%

% APPLYFILTER - Updates tool component when a filter edit changes.

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:26:11 $

% Get the current filter value and update accordingly.
filterStr = getWidgetValue(dialog,'selsigview_filterEdit');
this.TCPeer.setFilterText(filterStr);
this.TCPeer.update;





