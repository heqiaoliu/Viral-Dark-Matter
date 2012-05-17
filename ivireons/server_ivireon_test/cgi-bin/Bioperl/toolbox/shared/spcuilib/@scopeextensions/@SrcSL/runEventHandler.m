function runEventHandler(this, event)
%RUNEVENTHANDLER RUN event handler

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2010/03/31 18:42:19 $

setSnapShotMode(this, 'off');

this.TimeStatus = this.Controls.StatusBar.findwidget({'StdOpts','Frame'});

if ~isempty(this.InstallOnRun)
    selectChangeEventHandler(this, event);
elseif strcmp(this.ConnectionMode, 'floating')
    
    % Call the SelectionChange listener to attach to the currently selected
    % block in the system to which we are already attached.
    selectChangeEventHandler(this, event);
        
    update(this.Controls);
elseif this.Application.IsConnecting
    return;
elseif subscribeToData(this)
    installDataSource(this.Application, this);
elseif isequal(this.Application.DataSource, this) || isempty(this.Application.DataSource)
    
    % If we are the active source and we failed to connect (subscribeToData
    % returned false), use the screenMsg to put up the error.
    this.Application.screenMsg(this.ErrorMsg);
else
    
    % If we failed to connect, but are not active, use the errorHandler
    % dialog box to avoid overlaying the active display.
    uiscopes.errorHandler(this.ErrorMsg);
end

startVisualUpdater(this);

% [EOF]
