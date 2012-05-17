function close(this)
%CLOSE   Close the WiredSlSource and clear the userdata from the block.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/03/31 18:42:28 $

%Allow the datahandler to close itself
if ~isempty(this.DataHandler)
    close(this.DataHandler);
end

% Close the playback controls
if ~isempty(this.Controls)
    close(this.Controls);
end

% [EOF]
