
function close(this)
%CLOSE Closes the data source.
%  Shut down data source and playback controls.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/10/07 14:24:37 $

if ~isempty(this.DataHandler)
    close(this.DataHandler);  % Close data connection
end
close(this.controls);  % Remove UI widgets

if ~isempty(this.State)
    close(this.State);  % stop sim state events from firing
    this.State = [];
end
% [EOF]
