function simulinkrc
%SIMULINKRC Master startup M-file for Simulink
%   SIMULINKRC is automatically executed by Simulink during startup.
%
%       On multi-user or networked systems, the system manager can put
%       any messages, definitions, etc. that apply to all users here.
%
%   SIMULINKRC also invokes a STARTUPSL command if the file 'startupsl.m'
%   exists on the MATLAB path.

%   Copyright 1984-2007 The MathWorks, Inc.

%% Use the default paper set up by HG .. see hgrc.m for more details
defaultpaper = get(0,'DefaultFigurePaperType');
defaultunits = get(0,'DefaultFigurePaperUnits');

% Simulink defaults
set_param(0,'PaperType',defaultpaper);
set_param(0,'PaperUnits',defaultunits);

% Load preference setting of Simulink configuration set
try
  cs = getActiveConfigSet(0);
  cs.savePreferences('Load');
end

% Load other Simulink Preferences
try
    slinstallprefs;
end

% Execute startup M-file, if it exists.
startup_exists = exist('startupsl','file');
if startup_exists == 2 || startup_exists == 6
  evalin('base','startupsl')
end

% Customization manager
slcustomize
