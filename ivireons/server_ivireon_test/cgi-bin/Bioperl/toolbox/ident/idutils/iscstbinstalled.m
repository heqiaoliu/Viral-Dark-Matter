function boo = iscstbinstalled
%Check if Control System Toolbox is installed.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/04/28 03:21:56 $

%persistent isCSTBInstalledFlag;

%if isempty(isCSTBInstalledFlag)
boo = license('test','control_toolbox') && ~isempty(ver('control'));
%end

%boo = isCSTBInstalledFlag;