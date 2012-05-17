function connectToDataSource(this, hNewSource)
%CONNECTTODATASOURCE Connect to a data source.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/04/27 19:55:42 $

% Engage "completion" listener on NewSource event
% before calling newSource.  It's asynchronous due to
% the possibility of stopping a timer-based scheduler.
this.Listeners.NewSource.Callback = @(h, ev) onNewSource(this, hNewSource);
this.Listeners.NewSource.Enabled = 'on';

% The primary action:
% NOTE: 1st arg (doStop=true) indicates to stop the timer if running
newSource(this, hNewSource, ~isempty(this.DataSource));

% ---------------------------------------------------------
function onNewSource(this, hNewSource)
% continue processing after NewSource completes
% (synchronized: waits for existing datasource to stop, etc)

% Disengage "completion" listener
this.Listeners.NewSource.Enabled = 'off';

if strcmpi(hNewSource.ErrorStatus,'failure')
    if isempty(this.DataSource)
        this.screenMsg(hNewSource.ErrorMsg);
    elseif this.DataSource == hNewSource
        handleError(this.DataSource);
    else
        uiscopes.errorHandler(hNewSource.ErrorMsg, [this.getAppName(true) ' Error']);
    end
end

% [EOF]
