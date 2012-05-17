function latestConfiguration = getLatestConfiguration(this)
%GETLATESTCONFIGURATION Get the latestConfiguration.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/01/25 22:46:36 $

% Make sure that all the extensions have a chance to get their properties
% up to date.
iterator.visitImmediateChildrenConditional(this.ExtensionDb, ...
    @(hExtension) updatePropertyDb(hExtension), ...
    @(hExtension) hExtension.Config.Enable);

latestConfiguration = copyAllConfigs(this.ConfigDb);

% [EOF]
