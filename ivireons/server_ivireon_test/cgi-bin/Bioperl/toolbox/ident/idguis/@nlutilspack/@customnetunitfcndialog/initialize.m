function initialize(this,Owner,cf,customregobj)
% Build import dialog
% Owner: Java Frame or Dialog handle of the component that owns this
% dialog
% cf: callback function (cell array; not anonymous fcn to avoid memory leak)
% customregobj: copy of object bein modified (to be queires for its unit
% fcn to refresh the dialog header)

% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2010/03/22 03:48:57 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;

Title = 'Unit Function for Custom Network';
HelpID = {'customnetunitfcndlg.htm','Help: Specifying unit function for custom network'};

% buttons
PNLbtns = MJPanel(GridLayout(1,2,5,5));
javahandles.BTNOK = MJButton(sprintf('OK'));
javahandles.BTNOK.setName('nlgui:customnetunitfcndialog:OKButton');
set(javahandles.BTNOK,'ActionPerformedCallBack',{@localOK this});

javahandles.BTNcancel = MJButton(sprintf('Cancel'));
javahandles.BTNcancel.setName('nlgui:customnetunitfcndialog:CancelButton');
set(javahandles.BTNcancel,'ActionPerformedCallBack',{@localCancel this});

javahandles.BTNapply = MJButton(sprintf('Apply'));
javahandles.BTNapply.setName('nlgui:customnetunitfcndialog:ApplyButton');
set(javahandles.BTNapply,'ActionPerformedCallBack',{@localApply this});

javahandles.BTNhelp = MJButton(sprintf('Help'));
javahandles.BTNhelp.setName('nlgui:customnetunitfcndialog:HelpButton');
set(javahandles.BTNhelp,'ActionPerformedCallBack',{@localHelp HelpID});

PNLbtns.add(javahandles.BTNOK);
PNLbtns.add(javahandles.BTNcancel);
PNLbtns.add(javahandles.BTNapply);
PNLbtns.add(javahandles.BTNhelp);
PNLbtnsouter = MJPanel;
PNLbtnsouter.setBorder(BorderFactory.createEmptyBorder(5,5,0,5));
PNLbtnsouter.add(PNLbtns);

% build source selector panel
PNLsource = MJPanel;
PNLsource.setLayout(BoxLayout(PNLsource, BoxLayout.Y_AXIS));
PNLsource.setBorder(BorderFactory.createEtchedBorder); %BorderFactory.createEmptyBorder(4,2,10,2))

SourceLabel = MJLabel('Specify unit function as:');
HeaderLabel = MJLabel('                         ');

RadioButton1 = MJRadioButton('Function handle: ',true);
RadioButton1.setName('nlgui:customnetunitfcndialog:FcnHandleRadio');
hd = handle(RadioButton1, 'callbackproperties' );
hd.ActionPerformedCallback = {@LocalFcnHandleRadioCallback this};
RadioButton2 = MJRadioButton('MATLAB or MEX-file: ');
RadioButton2.setName('nlgui:customnetunitfcndialog:MorMexFileRadio');
hd = handle(RadioButton2, 'callbackproperties' );
hd.ActionPerformedCallback = {@LocalFileRadioCallback this};

RadioBtnGroup = ButtonGroup;
RadioBtnGroup.add(RadioButton1);
RadioBtnGroup.add(RadioButton2);

FcnHandleEdit = MJTextField(20);
FcnHandleEdit.setName('nlgui:customnetunitfcndialog:FcnHandleEdit');
%hd = handle(FcnHandleEdit, 'callbackproperties' );
%hd.ActionPerformedCallback = {@LocalSetFcnHandle this};

FilePathEdit = MJTextField(40);
FilePathEdit.setName('nlgui:customnetunitfcndialog:FilePathEdit');
hd = handle(FilePathEdit, 'callbackproperties' );
hd.ActionPerformedCallback = {@LocalSetFileName this};

BrowseButton = MJButton('Browse...');
BrowseButton.setName('nlgui:customnetunitfcndialog:BrowseButton');
hd = handle(BrowseButton, 'callbackproperties' );
hd.ActionPerformedCallback = {@LocalBrowseForFile this};

headerpanel = MJPanel;
headerpanel.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
headerpanel.setLayout(BoxLayout(headerpanel, BoxLayout.X_AXIS));
headerpanel.add(HeaderLabel);
headerpanel.add(Box.createHorizontalGlue);

subpanel0 = MJPanel;
subpanel0.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
subpanel0.setLayout(BoxLayout(subpanel0, BoxLayout.X_AXIS));
subpanel0.add(SourceLabel);
subpanel0.add(Box.createHorizontalGlue);

subpanel1 =  MJPanel; %(GridLayout(0,1));
subpanel1.setBorder(BorderFactory.createEmptyBorder(0,15,5,5));
subpanel1.setLayout(BoxLayout(subpanel1,BoxLayout.X_AXIS));
subpanel1.add(RadioButton1);
subpanel1.add(Box.createHorizontalStrut(5));
subpanel1.add(FcnHandleEdit);
subpanel1.add(Box.createHorizontalGlue);

subpanel2 =  MJPanel; %(GridLayout(0,1));
subpanel2.setBorder(BorderFactory.createEmptyBorder(0,15,5,5));
subpanel2.setLayout(BoxLayout(subpanel2,BoxLayout.X_AXIS));
subpanel2.add(RadioButton2);
subpanel2.add(Box.createHorizontalStrut(15));
subpanel2.add(FilePathEdit);
subpanel2.add(Box.createHorizontalStrut(5));
subpanel2.add(BrowseButton);
subpanel2.add(Box.createHorizontalGlue);

PNLsource.add(headerpanel);
PNLsource.add(Box.createVerticalStrut(10));
PNLsource.add(subpanel0);
PNLsource.add(Box.createVerticalStrut(5));
PNLsource.add(subpanel1);
PNLsource.add(Box.createVerticalStrut(5));
PNLsource.add(subpanel2);
PNLsource.add(Box.createVerticalStrut(10));

% disable mat file related widgets in the beginning
javaMethodEDT('setEnabled',FilePathEdit,false);
javaMethodEDT('setEnabled',BrowseButton,false);

javahandles.RadioButton1 = RadioButton1;
javahandles.RadioButton2 = RadioButton2;
javahandles.FilePathEdit = FilePathEdit;
javahandles.FcnHandleEdit = FcnHandleEdit;
javahandles.BrowseButton = BrowseButton;
javahandles.HeaderLabel = HeaderLabel;

% Build data panel
PNLdata = MJPanel(BorderLayout);
PNLdata.add(PNLsource,BorderLayout.NORTH);
PNLdata.add(PNLbtnsouter, BorderLayout.SOUTH);
PNLdata.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));

% build frame/dialog
this.Frame = MJDialog(Owner,Title,true);
this.Frame.setName('nlgui:customnetunitfcndialog:MainDialog');
hn = handle(this.Frame,'callbackproperties');
hn.WindowClosingCallback = {@localCancel this};
OPos = Owner.getLocation;
this.Frame.setLocation(OPos.x+50, OPos.y+100);
%this.Frame.setSize(Dimension(450,200));
this.Frame.getContentPane.add(PNLdata);
this.Handles = javahandles;
javaMethodEDT('pack',this.Frame);
this.refresh(cf,customregobj);

%--------------------------------------------------------------------------
function LocalBrowseForFile(hsrc,event,this)
% When browse button is pressed, show open file dialog box and store chosen
% file information

%processImportedObject
CurrentPath = pwd;
if ~isempty(this.LastPath)
    cd(this.LastPath);
end

[FileName, PathName] = ...
    uigetfile({'*.m','MATLAB files (*.m)';'*.mex*',...
    sprintf('MEX-files (*.%s)',mexext)},...
    'Unit Function for Custom Network');

if ~isempty(this.LastPath)
    cd(CurrentPath);
end

if ~isequal(FileName,0)
    %% Store the last path name
    this.FileNameWithPath = fullfile(PathName,FileName);
    
    %% Store the last path name
    this.LastPath = PathName;
    
    javaMethodEDT('setText',this.Handles.FilePathEdit,fullfile(PathName,FileName));
end

%--------------------------------------------------------------------------
function LocalSetFileName(hsrc,event,this)
% callback for MATLAB file/Mex-file edit box text enter

this.FileNameWithPath = get(hsrc,'Text');


%--------------------------------------------------------------------------
function LocalFcnHandleRadioCallback(hsrc,event,this)
% callback for Function handle radio button click

this.SelectedRadio = 1;
javaMethodEDT('setEnabled',this.Handles.FcnHandleEdit,true);
javaMethodEDT('setEnabled',this.Handles.FilePathEdit, false);
javaMethodEDT('setEnabled',this.Handles.BrowseButton, false);

%--------------------------------------------------------------------------
function LocalFileRadioCallback(hsrc,event,this)
% callback for MATLAB or MEX-file radio button click

this.SelectedRadio = 2;
javaMethodEDT('setEnabled',this.Handles.FcnHandleEdit,false);
javaMethodEDT('setEnabled',this.Handles.FilePathEdit, true);
javaMethodEDT('setEnabled',this.Handles.BrowseButton, true);

%-------------------------------------------------------------------------
function s = localApply(es,ed,this)
% Apply or OK button pressed
% s: status (0: fail; 1: pass)

%h: owning object that knowns how to process this update
%h = this.CallerInfo.Object;

s = false; %indicates failure to apply
if this.SelectedRadio==1
    % function handle was specified
    fcnString = get(this.Handles.FcnHandleEdit,'Text');
    if ~isempty(fcnString)
        try
            fcn = evalin('base',fcnString);
            if ~isa(fcn,'function_handle')
                ctrlMsgUtils.error('Ident:idguis:FcnHandleRequired')
            end
            filename = func2str(fcn);
            FCN = this.CallbackFcn; feval(FCN{1},FCN{2:end},fcn,filename);
            s = true;
        catch E
            iderrordlg(idlasterr(E), 'Invalid Unit Function Specification', this.Frame);
        end
    else
        iderrordlg('A function handle for unit function has not been specified.',...
            'Invalid Unit Function Specification', this.Frame);
    end
else
    % file was selected
    cwd = pwd;
    filenametext = get(this.Handles.FilePathEdit,'Text'); % browse button will populate the edit box too
    [pathname,filename] = fileparts(filenametext);
   
    if ~isempty(pathname)
        try
            cd(pathname)
        catch E
            iderrordlg(idlasterr(E), 'Invalid Unit Function Path Specification', this.Frame);
            return
        end
    end
    if ~isempty(filename)
        try
            fcn = str2func(filename);
            FCN = this.CallbackFcn; feval(FCN{1},FCN{2:end},fcn,filename);
            s = true;
        catch E
            iderrordlg(idlasterr(E), 'Invalid Unit Function Specification', this.Frame);
        end
    else
        iderrordlg('A file name for unit function has not been specified.',...
            'Invalid Unit Function Specification', this.Frame);
    end
    cd(cwd)
end

if s
    text1 = sprintf('Current value of Unit Function in the Custom Network: ''%s''',filename);
    javaMethodEDT('setText',this.Handles.HeaderLabel, text1);
end


%-------------------------------------------------------------------------
function localCancel(es,ed,this)
% close dialog: make it invisible

javaMethodEDT('setVisible',this.Frame,false);
% javaMethodEDT('dispose',this.Frame);

%-------------------------------------------------------------------------
function localHelp(es,ed, HelpID)

iduihelp(HelpID{:});

%-------------------------------------------------------------------------
function localOK(es,ed,this)

s = localApply([],[],this);
if s
    localCancel([],[],this)
end
