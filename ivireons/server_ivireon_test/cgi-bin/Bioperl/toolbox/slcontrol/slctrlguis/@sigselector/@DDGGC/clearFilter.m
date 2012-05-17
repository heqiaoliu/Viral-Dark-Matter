function clearFilter(this,dialog)
%

% CLEARFILTER - Clears the filter in the DDG dialog for selected signal
% viewer.

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:26:12 $

% Flush the filter
this.TCPeer.setFilterText('');
setWidgetValue(dialog,'selsigview_filterEdit','');
this.TCPeer.update;

