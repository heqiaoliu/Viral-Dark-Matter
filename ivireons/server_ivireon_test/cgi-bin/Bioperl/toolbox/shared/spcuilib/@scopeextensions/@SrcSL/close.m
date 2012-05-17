function close(this)
%CLOSE    Close out the Simulink source.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/03/31 18:42:09 $

stopVisualUpdater(this);

% Allow the data handler to close itself.
if ~isempty(this.DataHandler)
    close(this.DataHandler);
end

% Close the playback controls
if ~isempty(this.controls)
    close(this.controls);
end

% Disconnect from the data and event handler.
disconnectData(this);

% [EOF]
