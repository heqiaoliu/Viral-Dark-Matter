function updateTitleBar(this, ev) %#ok
%UPDATETITLEBAR Update title bar of scope figure

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2009/09/09 21:30:05 $

set(this.Parent, 'name', getScopeTitle(this.ScopeCfg, this));

msgDlg = sprintf('%s - Message Log', getDialogTitle(this));

setDialogTitle(this.MessageLog, msgDlg);

% Send the signal from main MPlay GUI to all dependent dialogs:
%   "time to update your titlebar!"
%

eventData = uiservices.EventData(this, 'UpdateDialogsTitleBarEvent', getAppName(this));

% Send synchronization event
%
send(this,'UpdateDialogsTitleBarEvent', eventData);

% [EOF]
