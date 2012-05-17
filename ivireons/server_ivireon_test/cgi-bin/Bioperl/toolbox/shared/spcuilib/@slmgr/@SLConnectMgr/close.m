function close(this)
%CLOSE close connection mgr from simulink model

%   Author(s): J. Yu
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/07 14:24:25 $



if ~isempty(this.hSignalData)
    close(this.hSignalData);
    this.hSignalData = [];
end

% [EOF]
