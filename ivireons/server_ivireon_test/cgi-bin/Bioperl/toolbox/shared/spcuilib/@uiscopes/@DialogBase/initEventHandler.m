function initEventHandler(this, hApplication)
%INITEVENTHANDLER additional initialization for scope special event 

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/31 18:44:20 $

% Listen for title bar name changes
this.listen_UpdateTitleBar = handle.listener(hApplication, ...
    'UpdateTitleBarEvent', @(hSrc, ev) updateTitleBar(this, ev, hApplication));

% Set DataSourceChange listener
this.listen_DataSourceChange = handle.listener(hApplication, ...
    'DataSourceChanged', @(hSrc, ev) onDataSourceChanged(this, ev));

% Set DataLoadedEvent listener
this.listen_DataLoadedEvent = handle.listener(hApplication, ...
    'DataLoadedEvent', @(hSrc, ev) dataLoadedHandler(this, ev));

% [EOF]
