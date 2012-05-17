function addRecentConfig(this, config)
%ADDRECENTCONFIG add configuration file to recent list

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/08/14 04:07:47 $

try
    this.RecentConfigurations.setMostRecent(config);
catch e
    uiscopes.errorHandler(uiservices.cleanErrorMessage(e));
end


% [EOF]
