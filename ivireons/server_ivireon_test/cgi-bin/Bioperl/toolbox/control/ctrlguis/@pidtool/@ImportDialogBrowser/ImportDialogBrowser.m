function this = ImportDialogBrowser(Tuner)
%SISOIMPORTDLG Builds the dialog

%   Author(s): R. Chen
%   Copyright 2009-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.3.2.1 $ $Date: 2010/06/24 19:32:30 $

%% Construct the object
this = pidtool.ImportDialogBrowser;
this.Tuner = Tuner;

%% Dialog Container
Frame = javaObjectEDT('com.mathworks.mwswing.MJDialog');
Frame.setName('ImportDialogBrowser');
Frame.setModal(true);
Frame.setTitle(pidtool.utPIDgetStrings('cst','importdlg_title'));
Frame.setResizable(false);
h = handle(Frame,'callbackproperties');
this.Handles.WindowDestroyListener = handle.listener(h,'WindowClosing',{@LocalDestroy this});

BorderLayout = javaObjectEDT('java.awt.BorderLayout',0,5);
MainPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout);
EmptyBorder = javaObjectEDT('javax.swing.border.EmptyBorder',10,10,5,10);
MainPanel.setBorder(EmptyBorder);
Frame.getContentPane.add(MainPanel);

%% Top Panel
BorderLayout = javaObjectEDT('java.awt.BorderLayout');
Panel1 = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout);
ComboBoxLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',pidtool.utPIDgetStrings('cst','importdlg_target_label'));
ComboBox = javaObjectEDT('com.mathworks.mwswing.MJComboBox',pidtool.utPIDgetStrings('cst','importdlg_target_combo',2));
ComboBox.setName('Target');
h = handle(ComboBox, 'callbackproperties' ); 
this.Handles.ComboBoxTargetListener = handle.listener(h, 'ActionPerformed', {@LocalTargetChanged this});
Panel1.add(ComboBoxLabel, java.awt.BorderLayout.WEST);
Panel1.add(ComboBox, java.awt.BorderLayout.CENTER);

%% Middle Panel
BorderLayout = javaObjectEDT('java.awt.BorderLayout');
Panel2 = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout);
Label1 = javaObjectEDT('com.mathworks.mwswing.MJLabel',pidtool.utPIDgetStrings('cst','importdlg_from_label'));

RadioButton1 = javaObjectEDT('com.mathworks.mwswing.MJRadioButton',pidtool.utPIDgetStrings('cst','importdlg_from_wks'));
RadioButton1.setName('RadioWorkspace');
RadioButton1.setSelected(true);
h = handle(RadioButton1, 'callbackproperties' ); 
this.Handles.RadioButtonWSListener = handle.listener(h, 'ActionPerformed', {@LocalGetWorkspaceVars this});
RadioButton2 = javaObjectEDT('com.mathworks.mwswing.MJRadioButton',pidtool.utPIDgetStrings('cst','importdlg_from_mat'));
RadioButton2.setName('RadioMATFile');
RadioButton2.setSelected(false);
h = handle(RadioButton2, 'callbackproperties' ); 
this.Handles.RadioButtonMATListener = handle.listener(h, 'ActionPerformed',{@LocalGetMatFileVars this});

%% Create button group, 
%% This allows only one radio buttonin the group selected at a time
RadioBtnGroup = javaObjectEDT('javax.swing.ButtonGroup');
RadioBtnGroup.add(RadioButton1);
RadioBtnGroup.add(RadioButton2);

FileEdit = javaObjectEDT('com.mathworks.mwswing.MJTextField',15);
FileEdit.setName('FileName');
h = handle(FileEdit, 'callbackproperties' ); 
this.Handles.EditFileListener = handle.listener(h, 'ActionPerformed', {@LocalSetFileName this});
BrowseButton = this.browsebutton;

FlowLayout = javaObjectEDT('java.awt.FlowLayout',java.awt.FlowLayout.LEFT);
SubPanel2a = javaObjectEDT('com.mathworks.mwswing.MJPanel',FlowLayout);
SubPanel2a.add(RadioButton2);
SubPanel2a.add(FileEdit);
SubPanel2a.add(BrowseButton);
FlowLayout = javaObjectEDT('com.mathworks.page.utils.VertFlowLayout',com.mathworks.page.utils.VertFlowLayout.LEFT);
SubPanel2b = javaObjectEDT('com.mathworks.mwswing.MJPanel',FlowLayout);
EmptyBorder = javaObjectEDT('javax.swing.border.EmptyBorder',0,15,0,0);
SubPanel2b.setBorder(EmptyBorder);
JunkPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
JunkPanel.add(RadioButton1);
SubPanel2b.add(JunkPanel);
SubPanel2b.add(SubPanel2a);
FlowLayout = javaObjectEDT('java.awt.FlowLayout',java.awt.FlowLayout.LEFT);
SubPanel2 = javaObjectEDT('com.mathworks.mwswing.MJPanel',FlowLayout);
SubPanel2.add(SubPanel2b);

Panel2.add(Label1,BorderLayout.NORTH);
Panel2.add(SubPanel2,BorderLayout.CENTER);

%% Initialize the table columns
tc = javaArray('java.lang.Object',3);
tc(1) = java.lang.String(pidtool.utPIDgetStrings('cst','importdlg_colname1'));
tc(2) = java.lang.String(pidtool.utPIDgetStrings('cst','importdlg_colname2'));
tc(3) = java.lang.String(pidtool.utPIDgetStrings('cst','importdlg_colname3'));
this.TableColumnNames = tc;

%% Create the table panel
TblPanel = this.tablepanel;
this.Handles.Table.setName('SystemDataTable');
this.Handles.Table.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_SELECTION);
this.Handles.TableModel.setColumnIdentifiers(tc)
h = handle(this.Handles.Table, 'callbackproperties' ); 
this.Handles.MouseListener = handle.listener(h, 'MouseClicked', {@LocalTableRowSelected this});

%% Create the NUP panel
BorderLayout = javaObjectEDT('java.awt.BorderLayout');
Panel3 = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout);
NUPLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',pidtool.utPIDgetStrings('cst','importdlg_nuplabel'));
NUPTextField = javaObjectEDT('com.mathworks.mwswing.MJFormattedTextField',java.lang.Integer(0));
NUPTextField.setName('NUPTEXTFIELD');
Panel3.add(NUPLabel,java.awt.BorderLayout.WEST);
Panel3.add(NUPTextField,java.awt.BorderLayout.CENTER);
NUPTextField.setEnabled(false);

%% Create the button panel
BtnPanel = this.buttonpanel;

%% Panel
panel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
panel.setLayout(java.awt.GridBagLayout);
GBc = java.awt.GridBagConstraints;
GBc.insets = java.awt.Insets(5,0,5,0);
GBc.gridx = 0;
GBc.gridy = 0;
GBc.fill = java.awt.GridBagConstraints.HORIZONTAL;
panel.add(Panel1,GBc);
GBc.gridy = 1;
panel.add(Panel2,GBc);
GBc.gridy = 2;
GBc.weighty = 1;
panel.add(TblPanel,GBc);
GBc.gridy = 3;
GBc.weighty = 0;
panel.add(Panel3,GBc);

MainPanel.add(panel,BorderLayout.CENTER);
MainPanel.add(BtnPanel, BorderLayout.SOUTH);

%% Store the handles for later use
this.Frame = Frame;
this.Handles.FileEdit = FileEdit;
this.Handles.ComboBox = ComboBox;
this.Handles.RadioButton1 = RadioButton1;
this.Handles.RadioButton2 = RadioButton2;
this.Handles.BrowseButton = BrowseButton;
this.Handles.NUPTextField = NUPTextField;

%% Set default state of radiobuttons to workspace(RadioButton1)
FileEdit.setEnabled(false);
BrowseButton.setEnabled(false);
% Get variable list from workspace
this.getwsvars;

%% ------------------------------------------------------------------------%
%% Function: LocalGetWorkSpaceVars
%% Purpose:  Generates the variable list from workspace 
%% ------------------------------------------------------------------------%
function LocalGetWorkspaceVars(hSrc, event, this) %#ok<*INUSL>
% Disable file edit field and browser button
this.Handles.FileEdit.setEnabled(false);
this.Handles.BrowseButton.setEnabled(false);
% Get variable list from workspace
this.getwsvars;

%% ------------------------------------------------------------------------%
%% Function: LocalSetFileName
%% Purpose:  Updates Filename
%% ------------------------------------------------------------------------%
function LocalSetFileName(hsrc,event,this)

this.FileName=get(hsrc,'Text');
this.Handles.FileEdit.setEnabled(true);
this.Handles.BrowseButton.setEnabled(true);
this.getmatfilevars;

%% ------------------------------------------------------------------------%
%% Function: LocalGetMatFileVars
%% Purpose:  Updates 
%% ------------------------------------------------------------------------
function LocalGetMatFileVars(hsrc,event,this)
this.Handles.FileEdit.setEnabled(true);
this.Handles.BrowseButton.setEnabled(true);
this.getmatfilevars
LocalTableRowSelected(hsrc,event,this);

function LocalDestroy(hsrc,event,this)
Frame = this.Frame;
delete(this);
Frame.dispose;

%% ------------------------------------------------------------------------%
%% Function: LocalTargetChanged
%% Purpose:  Enable NUP for @FRD
%% ------------------------------------------------------------------------%
function LocalTargetChanged(hsrc,event,this)
LocalTableRowSelected(hsrc,event,this);

%% ------------------------------------------------------------------------%
%% Function: LocalTableRowSelected
%% Purpose:  Enable NUP for @FRD
%% ------------------------------------------------------------------------%
function LocalTableRowSelected(hsrc,event,this)
if (this.Handles.Table.getSelectedRow>=0) && (this.Handles.ComboBox.getSelectedIndex == 0)
    % select a plant model 
    sys = this.VarData{this.Handles.Table.getSelectedRow+1};
    % import as sys
    convertFRD = false;
    if isa(sys,'ss') && hasInternalDelay(sys)
        hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
        try
            zpk(sys);
        catch %#ok<CTCH>
            convertFRD = true;
        end
    end
    if convertFRD || isa(sys,'frd') || isa(sys,'idfrd')
        this.Handles.NUPTextField.setEnabled(true);
    else
        this.Handles.NUPTextField.setEnabled(false);
    end
else
    this.Handles.NUPTextField.setEnabled(false);
end
