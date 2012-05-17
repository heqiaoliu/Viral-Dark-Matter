function retval = cacheSignalData(this)
%CACHESIGNALDATA 

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/31 18:42:08 $

% Validate the visual.
[b, exception] = validateSource(this.DataHandler);
if b
    [b, exception] = validateVisual(this, this.Application.Visual);
end

if b
    retval = true;
else
    this.ErrorStatus = 'failure';
    this.ErrorMsg    = exception.message;
    
    if ~isequal(this.Application.DataSource, this)
        % if current datasource is not from simulink and contains data, we
        % don't want to distroy the screen display
        disconnectState(this);
        if ~isempty(this.Controls)
            close(this.Controls);
        end
    else
        % Don't disconnect if we're in floating mode
        if ~this.isFloating
            disconnectState(this);
            disconnect(this.Application);
        end
    end
    retval = false;
end

%------------------------------------------------------------------------
function disconnect(hScope)
% Clear out all the referneces.

hScope.DataSource = [];

% Let anyone else know that we are removing the data.
eventData = uiservices.EventData(hScope, 'DataLoadedEvent', false);
send(hScope,'DataLoadedEvent', eventData);
send(hScope, 'DataReleased');

% Update the titlebar because we no longer have a source.
hScope.updateTitleBar;

% Turn off the display.
if screenMsg(hScope)
    screenMsg(hScope, false);
end

set(getDisplayHandles(hScope.Visual), 'Visible', 'off');


% [EOF]
