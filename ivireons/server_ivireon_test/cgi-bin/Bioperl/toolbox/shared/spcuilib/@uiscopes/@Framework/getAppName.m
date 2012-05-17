function appName = getAppName(this, isshort)
%GETAPPNAME Get the appName.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/03/09 19:34:57 $

if nargin < 2
    isshort = false;
end

appName = this.ScopeCfg.getAppName;
if ~isshort && this.ScopeCfg.getInstanceNumberTitle
    appName = sprintf('%s [%d]', appName, this.InstanceNumber);
end

% [EOF]
