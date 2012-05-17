function this = PickToolPanel()
% BUILDPICKTOOLPANEL  Build the panel for picking a design tool
%
 
% Author(s): John W. Glass 10-Aug-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/12/04 23:27:50 $

this = jDialogs.PickToolPanel;

% Create the panel
Panel = javaObjectEDT('com.mathworks.mwswing.MJPanel',false);
etchtype = javaObjectEDT('javax.swing.border.EtchedBorder');
loweredetched = javaMethodEDT('createEtchedBorder',...
    'javax.swing.BorderFactory',etchtype.LOWERED);
title = javaMethodEDT('createTitledBorder',...
            'javax.swing.BorderFactory',loweredetched, ...
                xlate('Introduction'));
Panel.setBorder(title);
BorderLayout = javaObjectEDT('java.awt.BorderLayout',5,5);
Panel.setLayout(BorderLayout);

% Create the center help panel
HelpPanel = javaObjectEDT('com.mathworks.mlwidgets.help.HelpPanel'); 

% Set the initial help topic
scdguihelp('control_design_wizard_overview',HelpPanel);
Panel.add(HelpPanel,BorderLayout.CENTER);

% Store the data
this.Panel = Panel;