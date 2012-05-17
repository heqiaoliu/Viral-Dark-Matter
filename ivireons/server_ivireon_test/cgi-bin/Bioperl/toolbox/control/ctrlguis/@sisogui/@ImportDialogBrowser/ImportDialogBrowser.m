function this = ImportDialogBrowser
%SISOIMPORTDLG Builds the dialog

%   Author(s): Craig Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $ $Date: 2007/02/06 19:50:35 $

import java.awt.*;
import javax.swing.*;
import com.mathworks.mwswing.*;
import com.mathworks.page.utils.VertFlowLayout;
import javax.swing.table.*;
import javax.swing.border.*;

%% Construct the object
this = sisogui.ImportDialogBrowser;

%% Dialog Container
Frame = awtcreate('com.mathworks.mwswing.MJDialog');
Frame.setModal(true);
Frame.setTitle(sprintf('Model Import'));
awtinvoke(Frame, 'setResizable(Z)', false);
h = handle(Frame,'callbackproperties');
h.WindowClosingCallback = {@LocalDestroy this};

MainPanel = MJPanel(BorderLayout(0,5));
MainPanel.setBorder(EmptyBorder(10,10,5,10));
Frame.getContentPane.add(MainPanel);

%% Top Panel
Panel1 = MJPanel(BorderLayout);
ComboBoxLabel = MJLabel(sprintf('Import model for '));
ComboBox = MJComboBox;
Panel1.add(ComboBoxLabel, BorderLayout.WEST);
Panel1.add(ComboBox, BorderLayout.CENTER);

%% Middle Panel
Panel2 = MJPanel(BorderLayout);
Label1 = MJLabel(sprintf('Import from:'));

RadioButton1 = MJRadioButton(sprintf('Workspace'));
h = handle(RadioButton1, 'callbackproperties' ); 
h.ActionPerformedCallback = {@LocalGetWorkspaceVars this};
RadioButton2 = MJRadioButton(sprintf('MAT File: '));
h = handle(RadioButton2, 'callbackproperties' ); 
h.ActionPerformedCallback = {@LocalGetMatFileVars this};

%% Create button group, 
%% This allows only one radio buttonin the group selected at a time
RadioBtnGroup = ButtonGroup;
RadioBtnGroup.add(RadioButton1);
RadioBtnGroup.add(RadioButton2);

FileEdit = MJTextField(15);
awtinvoke(FileEdit,'setName','FileName');
h = handle(FileEdit, 'callbackproperties' ); 
h.ActionPerformedCallback = {@LocalSetFileName this};
BrowseButton = this.browsebutton;

SubPanel2a = MJPanel(FlowLayout(FlowLayout.LEFT));
SubPanel2a.add(RadioButton2);
SubPanel2a.add(FileEdit);
SubPanel2a.add(BrowseButton);

SubPanel2b=MJPanel(VertFlowLayout(VertFlowLayout.LEFT));
SubPanel2b.setBorder(EmptyBorder(0,15,0,0));
JunkPanel = MJPanel;
JunkPanel.add(RadioButton1);
SubPanel2b.add(JunkPanel);
SubPanel2b.add(SubPanel2a);

SubPanel2 = MJPanel(FlowLayout(FlowLayout.LEFT));
SubPanel2.add(SubPanel2b);

Panel2.add(Label1,BorderLayout.NORTH);
Panel2.add(SubPanel2,BorderLayout.CENTER);

%% Initialize the table columns
tc = javaArray('java.lang.Object',3);
tc(1) = java.lang.String(sprintf('Available Models'));
tc(2) = java.lang.String(sprintf('Type'));
tc(3) = java.lang.String(sprintf('Order'));
this.TableColumnNames = tc;

%% Create the table panel
TblPanel = this.tablepanel;
this.Handles.TableModel.setColumnIdentifiers(tc)

%% Create the button panel
BtnPanel = this.buttonpanel;

%% Panel
panel = MJPanel(BorderLayout(0,10));
panel.add(Panel1,BorderLayout.NORTH);
panel.add(Panel2,BorderLayout.CENTER);
panel.add(TblPanel,BorderLayout.SOUTH);

MainPanel.add(panel,BorderLayout.CENTER);
MainPanel.add(BtnPanel, BorderLayout.SOUTH);

%% Store the handles for later use
this.Frame = Frame;
this.Handles.FileEdit = FileEdit;
this.Handles.ComboBox = ComboBox;
this.Handles.RadioButton1 = RadioButton1;
this.Handles.RadioButton2 = RadioButton2;
this.Handles.BrowseButton = BrowseButton;

%% Set default state of radiobuttons to workspace(RadioButton1)
awtinvoke(this.Handles.RadioButton1,'doClick()');

%% ------------------------------------------------------------------------%
%% Function: LocalGetWorkSpaceVars
%% Purpose:  Generates the variable list from workspace 
%% ------------------------------------------------------------------------%
function LocalGetWorkspaceVars(hSrc, event, this)
% Disable file edit field and browser button
awtinvoke(this.Handles.FileEdit,'setEnabled',false);
awtinvoke(this.Handles.BrowseButton,'setEnabled',false);
% Get variable list from workspace
this.getwsvars;

%% ------------------------------------------------------------------------%
%% Function: LocalSetFileName
%% Purpose:  Updates Filename
%% ------------------------------------------------------------------------%
function LocalSetFileName(hsrc,event,this)

this.FileName=get(hsrc,'Text');
awtinvoke(this.Handles.FileEdit,'setEnabled',true);
awtinvoke(this.Handles.BrowseButton,'setEnabled',true);
this.getmatfilevars;

%% ------------------------------------------------------------------------%
%% Function: LocalGetMatFileVars
%% Purpose:  Updates 
%% ------------------------------------------------------------------------
function LocalGetMatFileVars(hsrc,event,this)

awtinvoke(this.Handles.FileEdit,'setEnabled',true);
awtinvoke(this.Handles.BrowseButton,'setEnabled',true);
this.getmatfilevars

function LocalDestroy(hsrc,event,this)
Frame = this.Frame;
delete(this);
awtinvoke(Frame,'dispose');
