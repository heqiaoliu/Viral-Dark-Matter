function boo = idchecksimulinkinstalled
%Check if Simulink is installed.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.12.2 $ $Date: 2008/04/28 03:21:37 $

%persistent isSimulinkInstalledFlag;

%if isempty(isSimulinkInstalledFlag)
boo = license('test', 'Simulink') && ~isempty(ver('simulink'));
%end

%boo = isSimulinkInstalledFlag;
