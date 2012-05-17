function initialize(this,Owner,h,Type)
% Build import dialog
% Owner: Java Frame or Dialog handle of the component that owns the import
% dialog
% h: handle to the options object (mlnetoptions or regeditdialog)
% Type: variable type (class) to import

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/05/19 23:05:13 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

%workspace browser
this.Workbrowser = nlutilspack.varbrowser;
this.Workbrowser.typesallowed = {Type};

switch Type
    case 'network'
        Title = 'Import Neural Network Object';
        HelpID = {'nlnetworkimportdlg.htm','Help: Network Import Dialog'};
    case 'customreg'
        Title = 'Import Custom Regressors';
        HelpID = {'nlreglimportdlg.htm','Help: Custom Regressors Import Dialog'};
    otherwise
        Title = '';
        HelpID = '';
end
        

this.Workbrowser.javahandle.setName(['ident:varimportdlg:browser:',Type]);

% buttons
PNLbtns = MJPanel(GridLayout(1,2,5,5));
javahandles.BTNimport = MJButton(sprintf('Import'));
javahandles.BTNimport.setName('nlgui:varimportdlg:ImportButton');
set(javahandles.BTNimport,'ActionPerformedCallBack',@(es,ed)localImportObject(this,h));

javahandles.BTNclose = MJButton(sprintf('Close'));
javahandles.BTNclose.setName('nlgui:varimportdlg:CloseButton');
set(javahandles.BTNclose,'ActionPerformedCallBack',{@localClose this});

javahandles.BTNhelp = MJButton(sprintf('Help'));
javahandles.BTNhelp.setName('nlgui:varimportdlg:HelpButton');
set(javahandles.BTNhelp,'ActionPerformedCallBack',{@localHelp HelpID});

PNLbtns.add(javahandles.BTNimport);
PNLbtns.add(javahandles.BTNclose);
PNLbtns.add(javahandles.BTNhelp);
PNLbtnsouter = MJPanel;
PNLbtnsouter.add(PNLbtns);

% build source selector panel
PNLsource = MJPanel;
PNLsource.setLayout(BoxLayout(PNLsource, BoxLayout.Y_AXIS));
PNLsource.setBorder(BorderFactory.createEmptyBorder(4,2,10,2));

SourceLabel = MJLabel('Import from:');

RadioButton1 = MJRadioButton('Workspace',true);
hd = handle(RadioButton1, 'callbackproperties' ); 
hd.ActionPerformedCallback = {@LocalGetWorkspaceVars this};
RadioButton2 = MJRadioButton('MAT File: ');
hd = handle(RadioButton2, 'callbackproperties' ); 
hd.ActionPerformedCallback = {@LocalGetMatFileVars this};

RadioBtnGroup = ButtonGroup;
RadioBtnGroup.add(RadioButton1);
RadioBtnGroup.add(RadioButton2);

FilePathEdit = MJTextField(20);
hd = handle(FilePathEdit, 'callbackproperties' ); 
hd.ActionPerformedCallback = {@LocalSetFileName this};

BrowseButton = MJButton('Browse...');
hd = handle(BrowseButton, 'callbackproperties' ); 
hd.ActionPerformedCallback = {@LocalBrowseForMatFile this};

subpanel0 = MJPanel;
subpanel0.setLayout(BoxLayout(subpanel0, BoxLayout.X_AXIS));
subpanel0.add(SourceLabel);
subpanel0.add(Box.createHorizontalGlue);

subpanel1 = MJPanel;
subpanel1.setLayout(BoxLayout(subpanel1, BoxLayout.X_AXIS));
subpanel1.setBorder(BorderFactory.createEmptyBorder(5,15,5,2));
subpanel1.add(RadioButton1);
subpanel1.add(Box.createHorizontalGlue);

subpanel2 =  MJPanel; %(GridLayout(0,1));
subpanel2.setBorder(BorderFactory.createEmptyBorder(0,15,5,2));
subpanel2.setLayout(BoxLayout(subpanel2,BoxLayout.X_AXIS));
subpanel2.add(RadioButton2);
subpanel2.add(Box.createHorizontalStrut(5));
subpanel2.add(FilePathEdit);
subpanel2.add(Box.createHorizontalStrut(5));
subpanel2.add(BrowseButton);
subpanel2.add(Box.createHorizontalGlue);

PNLsource.add(subpanel0);
PNLsource.add(subpanel1);
PNLsource.add(subpanel2);

% disable mat file related widgets in the beginning
javaMethodEDT('setEnabled',FilePathEdit,false);
javaMethodEDT('setEnabled',BrowseButton,false);

javahandles.RadioButton1 = RadioButton1;
javahandles.RadioButton2 = RadioButton2;
javahandles.FilePathEdit = FilePathEdit;
javahandles.BrowseButton = BrowseButton;

% Build data panel
PNLdata = MJPanel(BorderLayout);
PNLbrowse = MJPanel(GridLayout(1,0));
PNLbrowse.add(this.workbrowser.javahandle);
PNLdata.add(PNLsource,BorderLayout.NORTH);
PNLdata.add(PNLbrowse,BorderLayout.CENTER);
PNLdata.add(PNLbtnsouter, BorderLayout.SOUTH);
PNLdata.setBorder(BorderFactory.createEmptyBorder(10,10,10,10));

% build frame/dialog
this.Frame = MJDialog(Owner,Title,false);
h = handle(this.Frame,'callbackproperties');
h.WindowClosingCallback = {@localClose this};
OPos = Owner.getLocation; this.Frame.setLocation(OPos.x+15, OPos.y+20);
this.Frame.setSize(Dimension(450,400));
this.Frame.getContentPane.add(PNLdata);
this.Importhandles = javahandles;

this.Workbrowser.javahandle.getColumnOptions.setDefaultWidth(75);
this.Workbrowser.javahandle.setMinAutoExpandColumnWidth(100);

% refresh variable browser
this.Workbrowser.open([1 NaN; NaN 1]);

%-------------------- Local Functions ---------------------------
function LocalSetFileName(hsrc,event,this)

this.Workbrowser.ImportSource = 'file';
this.Workbrowser.filename = get(hsrc,'Text');
%javaMethodEDT('setEnabled',this.Handles.FileEdit,true);
%javaMethodEDT('setEnabled',this.Handles.BrowseButton,true);
this.Workbrowser.open([1 NaN; NaN 1]); %refresh table

%--------------------------------------------------------------------------
function LocalBrowseForMatFile(hsrc,event,this)

this.Workbrowser.ImportSource = 'file';
CurrentPath = pwd;
if ~isempty(this.LastPath)
    cd(this.LastPath);
end

[FileName, PathName] = uigetfile('*.mat','Import file:');

if ~isempty(this.LastPath)
    cd(CurrentPath);
end

if ~isequal(FileName,0)
    %% Store the last path name
    this.Workbrowser.filename = fullfile(PathName,FileName);
    
    %% Store the last path name
    this.LastPath = PathName;
    
    javaMethodEDT('setText',this.Importhandles.FilePathEdit,fullfile(PathName,FileName));
    
    this.Workbrowser.open([1 NaN; NaN 1]); %refresh table
end

%--------------------------------------------------------------------------
function LocalGetMatFileVars(hsrc,event,this)

this.Workbrowser.ImportSource = 'file';
this.Workbrowser.filename = get(this.Importhandles.FilePathEdit,'Text');
javaMethodEDT('setEnabled',this.Importhandles.FilePathEdit,true);
javaMethodEDT('setEnabled',this.Importhandles.BrowseButton,true);

this.Workbrowser.open([1 NaN; NaN 1]); %refresh table

%--------------------------------------------------------------------------
function LocalGetWorkspaceVars(hsrc,event,this)

this.Workbrowser.ImportSource = 'workspace';
javaMethodEDT('setEnabled',this.Importhandles.FilePathEdit,false);
javaMethodEDT('setEnabled',this.Importhandles.BrowseButton,false);

this.Workbrowser.open([1 NaN; NaN 1]); %refresh table

%--------------------------------------------------------------------------
function localImportObject(this,h)

currentRows = double(this.workbrowser.javahandle.getSelectedRows);
%ImportFailed = false;
if ~isempty(currentRows)
    selectedvar = this.Workbrowser.variables(currentRows(1)+1);
    
    if strcmpi(this.Workbrowser.ImportSource,'workspace')
        % import from workspace
        obj = evalin('base', selectedvar.name);
    else
        % import from file
        dat = load(this.Workbrowser.filename,selectedvar.name);
        obj = dat.(selectedvar.name);
    end

    h.processImportedObject(obj,selectedvar.name);
   
end

%-------------------------------------------------------------------------
function localClose(es,ed,this)

javaMethodEDT('setVisible',this.Frame,false);

%-------------------------------------------------------------------------
function localHelp(es,ed, HelpID)

iduihelp(HelpID{:});
