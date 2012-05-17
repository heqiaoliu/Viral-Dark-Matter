function slident_m
% In case Simulink is not installed, issue a message indicating that.
% This function is a callback to Block Library menu option in the Start
% menu of MATLAB for System Identification Toolbox.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2008/10/31 06:10:55 $

if idchecksimulinkinstalled
    open_system('slident');
else
    errordlg(ctrlMsgUtils.message('Ident:simulink:SimulinkNotAvailable'),...
        'Block Library','modal')
end
