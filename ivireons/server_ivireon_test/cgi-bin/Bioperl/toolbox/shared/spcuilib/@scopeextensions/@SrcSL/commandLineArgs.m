function args = commandLineArgs(this)
%COMMANDLINEARGS 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/09/15 20:47:22 $

if isConnected(this)
    args = commandLineArgs(this.DataHandler);
else
    args = {[]};
end

% [EOF]
