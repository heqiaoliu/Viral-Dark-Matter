function onDataSourceChanged(this)
%ONDATASOURCECHANGED React to DataSourceChanged events.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:41:34 $

this.NewDataListener = addNewDataListener(this.Application, makeOnNewData(this));

% -------------------------------------------------------------------------
function cb = makeOnNewData(this)

cb = @(hSource) onNewData(this, hSource);

% [EOF]
