function buildPanel(this)
%buildPanel SISO Tool Architecture panel

%   Author(s): C. Buhr
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.6.10 $  $Date: 2010/04/30 00:36:36 $

import java.awt.*;
import com.mathworks.page.utils.VertFlowLayout;

%% Main Panel
MainPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);

%% Current Architecture Panel
CurrentArchitecturePanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(0, 10));

%% Determine the configuration
isconfig0 = isequal(this.SISODB.LoopData.getconfig,0);

%% Create the Architecture description panel
if isconfig0
    CurrentArchitectureDescription = this.sisodb.getNode.createSummaryArea;
    CurrentArchitecturePanel.add(CurrentArchitectureDescription,BorderLayout.CENTER);
else
    title  = javaMethodEDT('createTitledBorder','javax.swing.BorderFactory', ...
        sprintf('Current Architecture: '));
    javaObjectEDT(title);
    ArchitectureIcon = javaObjectEDT('javax.swing.ImageIcon', ...
        sisogui.getIconPath(this.SISODB.LoopData.getconfig));
    CurrentArchitectureDescription = javaObjectEDT('com.mathworks.mwswing.MJLabel',ArchitectureIcon);
    CurrentArchitecturePanel.setBorder(title);
    CurrentArchitecturePanel.add(CurrentArchitectureDescription,BorderLayout.CENTER);
end

%% Create the buttons
LoopOpeningButton = javaObjectEDT('com.mathworks.mwswing.MJButton', ...
    sprintf('Loop Configuration...'));
LoopOpeningButton.setName('LoopOpeningButton');
LoopOpeningButtonDescr = javaObjectEDT('com.mathworks.mwswing.MJLabel', ...
    sprintf('Configure additional loop openings for multi-loop design.'));
ImportButton = javaObjectEDT('com.mathworks.mwswing.MJButton', ...
    sprintf('System Data ...'));
ImportButton.setName('ImportButton');
ImportButtonDescr = javaObjectEDT('com.mathworks.mwswing.MJLabel', ...
    sprintf('Import data for compensators and fixed systems.'));
C2DButton = javaObjectEDT('com.mathworks.mwswing.MJButton', ...
    sprintf('Sample Time Conversion ...'));
C2DButton.setName('C2DButton');
C2DButtonDescr = javaObjectEDT('com.mathworks.mwswing.MJLabel', ...
    sprintf('Change the sample time of the design.'));
C2DButton.setEnabled(~isa(this.SISODB.LoopData.Plant.getP,'ltipack.frddata'));

UncertaintyButton = javaObjectEDT('com.mathworks.mwswing.MJButton', ...
    ctrlMsgUtils.message('Control:compDesignTask:strMultiModelButtonLabel'));
UncertaintyButton.setName('MultiModelButton');
UncertaintyButtonDescr = javaObjectEDT('com.mathworks.mwswing.MJLabel', ...
    ctrlMsgUtils.message('Control:compDesignTask:strMultiModelTextLabel'));
UncertaintyButton.setEnabled(isUncertain(this.SISODB.LoopData.Plant));



h = handle(LoopOpeningButton, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalConfigureLoops,this};

h = handle(ImportButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalImport this.sisodb};
                            
h = handle(C2DButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalTsConversion this.sisodb};

h = handle(UncertaintyButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalConfigureMultiModelOptions this.sisodb};

%% Create the button pPanel
ButtonPanel= javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);

gbc           = GridBagConstraints;
gbc.insets    = Insets(10,5,0,5);
gbc.anchor    = GridBagConstraints.NORTHWEST;
gbc.weighty = 0;
gbc.fill      = GridBagConstraints.BOTH;

if ~isconfig0
    ArchitectureButton = javaObjectEDT('com.mathworks.mwswing.MJButton', ...
        sprintf('Control Architecture ...'));
    ArchitectureButton.setName('ArchitectureButton');
    ArchitectureButtonDescr = javaObjectEDT('com.mathworks.mwswing.MJLabel', ...
        sprintf('Modify architecture, labels and feedback signs.'));
    h = handle(ArchitectureButton,'callbackproperties');
    h.ActionPerformedCallback = {@LocalChangeArchitecture this.sisodb};
    %% Layout
    gbc.weightx = 0;
    gbc.gridwidth = GridBagConstraints.RELATIVE;
    ButtonPanel.add(ArchitectureButton,gbc);
    gbc.weightx = 1;
    gbc.gridwidth = GridBagConstraints.REMAINDER;
    ButtonPanel.add(ArchitectureButtonDescr,gbc);
end

gbc.weightx = 0;
gbc.gridwidth = GridBagConstraints.RELATIVE;
ButtonPanel.add(LoopOpeningButton,gbc);
gbc.weightx = 1;
gbc.gridwidth = GridBagConstraints.REMAINDER;
ButtonPanel.add(LoopOpeningButtonDescr,gbc);
gbc.weightx = 0;
gbc.gridwidth = GridBagConstraints.RELATIVE;
ButtonPanel.add(ImportButton,gbc);
gbc.weightx = 1;
gbc.gridwidth = GridBagConstraints.REMAINDER;
ButtonPanel.add(ImportButtonDescr,gbc);
gbc.weightx = 0;
gbc.gridwidth = GridBagConstraints.RELATIVE;
ButtonPanel.add(C2DButton,gbc);
gbc.weightx = 1;
gbc.gridwidth = GridBagConstraints.REMAINDER;
ButtonPanel.add(C2DButtonDescr,gbc);
gbc.weightx = 0;
gbc.gridwidth = GridBagConstraints.RELATIVE;
ButtonPanel.add(UncertaintyButton,gbc);
gbc.weightx = 1;
gbc.gridwidth = GridBagConstraints.REMAINDER;
ButtonPanel.add(UncertaintyButtonDescr,gbc);

%% Store handles for later use
this.Handles = struct('Panel', MainPanel, ...
                      'CurrentArchitectureDescription' ,CurrentArchitectureDescription, ...
                      'C2DButton', C2DButton,...
                      'UncertaintyButton', UncertaintyButton);

%% Put the panel together
gbc           = GridBagConstraints;
gbc.insets    = Insets(10,5,0,5);
gbc.anchor    = GridBagConstraints.NORTHWEST;
gbc.gridwidth = GridBagConstraints.REMAINDER;

if ~isequal(this.SISODB.LoopData.getconfig,0)
    gbc.weighty = 0;
    gbc.fill      = GridBagConstraints.HORIZONTAL;
else
    gbc.weighty = 1;
    gbc.fill      = GridBagConstraints.BOTH;
end
gbc.weightx = 1;

%% Add the panels
MainPanel.add(CurrentArchitecturePanel,gbc);
gbc.weighty = 0;
gbc.fill      = GridBagConstraints.HORIZONTAL;
MainPanel.add(ButtonPanel,gbc);     

%% Add a filler panel for the non-config 0 case 
if isconfig0
    gbc.weighty = 0;
    gbc.fill      = GridBagConstraints.BOTH;
    MainPanel.add(javaObjectEDT('com.mathworks.mwswing.MJPanel'),gbc);
else    
    gbc.weighty = 1;
    gbc.fill      = GridBagConstraints.BOTH;
    MainPanel.add(javaObjectEDT('com.mathworks.mwswing.MJPanel'),gbc);
end

                            
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
function LocalConfigureLoops(es,ed,this)

h = sisogui.OpenLoopConfigDialog(this.SISODB.Loopdata);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalImport(es,ed,sisodb)

projectframe = slctrlexplorer;
h = sisogui.ImportDialog(sisodb,projectframe);
h.show;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalChangeArchitecture(es,ed,sisodb)

h = sisogui.ArchitectureDialog(sisodb);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalTsConversion(es,ed,sisodb)
%---Callback for the Convert to Discrete/Continuous menu 
% Check at most one model in system is dynamic
LoopData = sisodb.LoopData;

% static status for fixed models
booFixed = isstatic(LoopData.Plant);

% static status for tuned models
Tuned = LoopData.C;
numTuned = length(Tuned);
booTuned = false(numTuned,1);
for cnt = 1:numTuned
    booTuned(cnt) = isStatic(Tuned(cnt));
end

boo = [booFixed; booTuned];
numstatic = sum(boo); % number of static components
numComponents = length(boo); % number of components

% If more than one dynamic model display warning
if numstatic < numComponents - 1
    WarnTxt = {'Continuous/discrete conversions are performed' ; ...
            'independently on each of the components.';...
            ' ';...
            'The resulting feedback loop may not accurately describe';...
            'your system when all components have dynamics.';...
            ' '};
    if strcmp(questdlg(WarnTxt,'Conversion Warning','OK','Cancel','Cancel'),'Cancel')
        return
    end
end

% Open conversion GUI (modal)
if isequal(LoopData.getconfig,0)
    % Add a drawnow to prevent thread lock between closing the question dialog 
    % and the creation of the options dialog which is an MJDialog.
    drawnow
    jDialogs.ControlDesignOptionsDialog(sisodb);
else
    sisodb.c2dtool;
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalConfigureMultiModelOptions(es,ed,sisodb)

sisodb.DesignTask.showMultiModelDialog;



