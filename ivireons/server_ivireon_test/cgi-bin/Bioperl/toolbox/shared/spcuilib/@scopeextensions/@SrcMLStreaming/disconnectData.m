function disconnectData(this)
%disconnectData Cleans up the data handler object and deletes it.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/12/04 23:20:01 $

% Pass message to data handler
if ~isempty(this.DataHandler)
    disconnectData(this.DataHandler);
end

% [EOF]
