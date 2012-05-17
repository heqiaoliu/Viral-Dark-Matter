function val = scdgetpref(prefname,varargin)
%SCDGETPREF Set Simulink Control Design preferences.
%   PREFVALUE = SCDGETPREF(PREFNAME) gets Simulink Control Design preference
%   PREFNAME value PREFVALUE.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2009/08/08 01:19:29 $ $Author: batserve $

if ispref('SimulinkControlDesign',prefname)
    val = getpref('SimulinkControlDesign',prefname);
else
    switch prefname
        case 'StoreDiagnosticsInspectorInfo'
            val = 'on';
        case 'DefaultLinearizationPlot'
            val = 'step';
        case 'UseParallel'
            val = 'off';
        otherwise
            ctrlMsgUtils.error('Slcontrol:linutil:UndefinedSCDPreference')
    end
    addpref('SimulinkControlDesign',prefname,val)
end
            
if nargin > 1 && strcmp(prefname,'DefaultLinearizationPlot') && strcmp(varargin{1},'Initialize')
    val = {'step','bode','bodemag','nichols','nyquist','sigma','pzmap','iopzmap','lsim','initial','impulse',val};
    % Convert to GUI label
    for ct = 1:numel(val)
        val{ct} = slctrlguis.plotcmd2label(val{ct});
    end
end
