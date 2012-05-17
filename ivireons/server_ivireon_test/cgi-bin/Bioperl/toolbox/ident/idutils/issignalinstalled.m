function boo = issignalinstalled
%Check if Signal Processing Toolbox is installed.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/04/28 03:21:59 $

%persistent isSignalInstalledFlag;

%if isempty(isSignalInstalledFlag)
boo =  license('test','signal_toolbox') && ~isempty(ver('signal'));
%end

%boo = isSignalInstalledFlag;