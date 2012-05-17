function scdlaunch(typekey)
% SCDLAUNCH  Launch the CETM
%
% TYPEKEY: 'linearization_simulink'  for Linearization Task
% TYPEKEY: 'compensator_design_simulink' for Simulink Compensator Design Task

% Author(s): John W. Glass 17-Nov-2005
% Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2010/03/08 21:48:17 $

[~,W] = slctrlexplorer('initialize');
newdlg = explorer.NewProjectDialog(W, typekey);
javaMethodEDT('setVisible', newdlg.Dialog, true);
