function this = OpcondImport(oppoint,validprojects,helptopicID,varargin)
% Builds the dialog
%
%  Optional arguments (Property Value Pairs)
%    'MultiSelect' - true/false

%   Author(s): John Glass
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $ $Date: 2008/12/04 23:27:48 $

% Construct the object
this = jDialogs.OpcondImport;
ParentFrame = slctrlexplorer;

% Parse the property pairs
MultiSelect = false;
% Set the user defined properties
nPPairs = (nargin-3)/2;
for ct = 1:(nPPairs)
    switch varargin{2*ct-1}
        case 'MultiSelect'
            MultiSelect = varargin{2*ct};
    end
end

% Store an operating point to copy if needed.
this.OpPoint = oppoint;

% Store the number of states expected
nStates = 0;
for ct = 1:numel(oppoint.States)
    nStates = nStates + oppoint.States(ct).Nx;
end
this.NxDesired = nStates;

% Dialog Container
if isempty(validprojects)
    selectproject = false;
else
    selectproject = true;
end

% Create the hash table with the dialog strings
keystrcell = {'DialogTitle',xlate('Operating Point Import');...
              'Step1Label' xlate('Step 1: Select a source for the operating point.');...
              'SelectFromProject', xlate('Select from project:');...
              'Workspace',xlate('Workspace');...
              'MATFile',xlate('MAT-file:');...
              'Browse',xlate('Browse');...
              'AvailableDataColName', xlate('Available Data');...
              'TypeColName', xlate('Type');...
              'SizeColName', xlate('Size');...
              'Step2Label', xlate('Step 2: Select an operating point and click import.');...
              'Import', xlate('Import');...
              'Help', xlate('Help');...
              'Cancel', xlate('Cancel')};
strhash = cell2hashtable(slcontrol.Utilities,keystrcell);

Frame = javaObjectEDT('com.mathworks.toolbox.slcontrol.Dialogs.OperatingPointImportDialog',ParentFrame,selectproject,strhash);
Frame.setListSelectionMultiMode(MultiSelect);

% Set the callbacks
% Add listener for the case selected node is destroyed.
TaskNodeListener = handle.listener(handle(getObject(getSelected(slctrlexplorer))), 'ObjectBeingDestroyed',...
                                    {@LocalCancel this});
this.Listeners = [this.Listeners;TaskNodeListener];

h = handle(Frame.getSelectProjectRadioButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalGetProjectVars this};

% Project Panel
ProjectCombo = Frame.getProjectCombo;
for ct = 1:numel(validprojects)
    ProjectCombo.addItem(validprojects(ct).Label);
end

h = handle(Frame.getProjectCombo, 'callbackproperties');
h.ItemStateChangedCallback = {@LocalGetProjectVars this};

% Workspace Panel
h = handle(Frame.getWorkspaceRadioButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalGetWorkspaceVars this};

% File Panel
h = handle(Frame.getMATFileRadioButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalGetMatFileVars this};

h = handle(Frame.getFileEdit, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalSetFileName, this};

h = handle(Frame.getBrowseButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalBrowseFiles this};

% Button Panel 
h = handle(Frame.getImportButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalImport this};
h = handle(Frame.getCancelButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalCancel this};
h = handle(Frame.getHelpButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalHelp, this, helptopicID};

% Store the handles for later use
this.Frame = Frame;
this.show

% Set the initial table data
if isempty(validprojects)
    LocalGetWorkspaceVars([],[],this);
else
    this.Projects = validprojects;
    LocalGetProjectVars([],[],this);
end

% ------------------------------------------------------------------------%
%  Function: LocalBrowseFiles
%  Purpose:  File browser
%  ------------------------------------------------------------------------%
function LocalBrowseFiles(hSrc, event, this)

CurrentPath=pwd;
if ~isempty(this.LastPath),
    cd(this.LastPath);
end

[FileName, PathName] = uigetfile('*.mat','Import file:');

if ~isempty(this.LastPath),
    cd(CurrentPath);
end

if ~isequal(FileName,0)
    % Store the last path name
    this.FileName = FileName;
    % Store the last path name
    this.LastPath = PathName;
    % Note: although setText is threadsafe according to JAVA documentation
    % matlab throws a thread warning currently, this line can be rewritten
    % as a direct java method call if warning is turned off
    javaMethodEDT('setText',this.Frame.getFileEdit,FileName);
    this.getmatfilevars;
end

% ------------------------------------------------------------------------%
%  Function: LocalGetWorkSpaceVars
%  Purpose:  Generates the variable list from workspace 
%  ------------------------------------------------------------------------%
function LocalGetWorkspaceVars(hSrc, event, this)

Vars = evalin('base','whos');
[VarNames, DataModels] = getmodels(this,Vars,'base');
this.updatetable(VarNames,DataModels);

% ------------------------------------------------------------------------%
%  Function: LocalGetProjectVars
%  Purpose:  Generates the variable list from workspace 
%  ------------------------------------------------------------------------%
function LocalGetProjectVars(hSrc, event, this)

ind = this.Frame.getProjectCombo.getSelectedIndex + 1;
project = this.Projects(ind);
validconditions = project.OperatingConditions.getChildren;

VarNames = get(validconditions,{'Label'});
DataModels = get(validconditions,{'OpPoint'});
this.updatetable(VarNames,DataModels);

% ------------------------------------------------------------------------%
%  Function: LocalSetFileName
%  Purpose:  Updates Filename
%  ------------------------------------------------------------------------%
function LocalSetFileName(hsrc,event,this)

this.FileName=get(hsrc,'Text');
this.getmatfilevars;

% ------------------------------------------------------------------------%
%  Function: LocalGetMatFileVars
%  Purpose:  Updates 
%  ------------------------------------------------------------------------
function LocalGetMatFileVars(hsrc,event,this)

this.getmatfilevars

% ------------------------------------------------------------------------%
% Function: LocalClose
% Purpose:  Destroy dialog Frame
% ------------------------------------------------------------------------%
function LocalCancel(hSrc, event, this)

javaMethodEDT('dispose',this.Frame);

% ------------------------------------------------------------------------%
% Function: LocalImport
% Purpose:  Import selected model
% ------------------------------------------------------------------------%
function LocalImport(hSrc, event, this)

this.import

% ------------------------------------------------------------------------%
% Function: LocalHelp
% Purpose:  Open Help
% ------------------------------------------------------------------------%
function LocalHelp(hSrc, event, this, helptopicID)

switch helptopicID
    case 'import'
        scdguihelp('import',this.Frame);
    case 'import_initial_values'
        scdguihelp('import_initial_values',this.Frame);
end

