function close(this)
%CLOSE   Close the SrcSLSource.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/04/21 21:47:34 $

%Allow the datahandler to close itself
if ~isempty(this.DataHandler)
    close(this.DataHandler);
end

% Close the playback controls
if ~isempty(this.Controls)
    close(this.Controls);
end

%Delete listeners on the source object
for i = 1:length(this.Listener)
    delete(this.Listener{i});
end
this.Listener = [];

% [EOF]
