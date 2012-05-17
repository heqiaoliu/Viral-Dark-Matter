function disengageConnection(this)
%disengageConnection Called when source disengages a connection.
%   Overloaded by extensions requiring tear-down actions.

% Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/05/20 00:20:28 $

this.ActiveSource = false;

if ~isempty(this.DataHandler)
    disconnectData(this.DataHandler);
end

disconnectData(this);

if ~isempty(this.Controls)
    close(this.Controls);
end

% [EOF]
