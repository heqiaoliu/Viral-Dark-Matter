function loadRecentConfig(this, item)
%LOADRECENTCONFIG load config file from recent list

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/06/11 16:06:21 $

try
    if nargin < 2
        item = this.RecentConfigurations.SelectedItem;
    end
    
    [loaded, config] = this.Application.ExtDriver.loadConfigSet(item);
    if loaded
        this.addRecentConfig(config);
    end
catch e
    uiscopes.errorHandler(uiservices.cleanErrorMessage(e));
end

% [EOF]
