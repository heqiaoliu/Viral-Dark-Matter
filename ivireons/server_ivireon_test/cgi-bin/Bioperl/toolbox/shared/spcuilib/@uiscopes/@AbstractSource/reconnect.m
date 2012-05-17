function reconnect(this)
%RECONNECT reconnect data

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/23 18:45:49 $

if ~isempty(this.DataHandler)
    reconnectData(this.DataHandler);
end

% [EOF]
