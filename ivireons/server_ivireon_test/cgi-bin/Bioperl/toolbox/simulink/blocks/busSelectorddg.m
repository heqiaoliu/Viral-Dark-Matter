function dlgStruct = busSelectorddg(source, block)

% Copyright 2003-2010 The MathWorks, Inc.

% Getting the BusStruct and InputSignals is expensive so get it now and 
% cache it in the block's UserData
if  ~isfield(block.UserData, 'flag') && ~block.isHierarchyReadonly
    ud.oldUserData = block.UserData;
    
    modelHandle = busSelectorddg_cb([], 'getModelHandleFromBlock', block);
    strictBusLvl = modelHandle.StrictBusMsg;
    ud.flag = slfeature('EditTimeBusPropagation') && ...
              (strcmp(strictBusLvl, 'ErrorLevel1') || ...
               strcmp(strictBusLvl, 'WarnOnBusTreatedAsVector') || ...
               strcmp(strictBusLvl, 'ErrorOnBusTreatedAsVector'));
    
    if ud.flag
        ud.signalHierarchy = block.SignalHierarchy;  
    else
        ud.busStruct       = block.BusStruct;
        ud.inputSignals    = block.InputSignals;
    end 
    block.UserData  = ud;
end

% Top group is the block description
descText.Name                       = block.BlockDescription;
descText.Type                       = 'text';
descText.WordWrap                   = true;

descGroup.Name                      = block.BlockType;
descGroup.Type                      = 'group';
descGroup.Items                     = {descText};
descGroup.RowSpan                   = [1 1];
descGroup.ColSpan                   = [1 1];

% Bottom group is the block parameters
% Input Group --------------------------
[items handles] = busSelectorddg_cb([], 'getTreeItems', block);
inputsTree.Name                     = 'Signals in the bus';
inputsTree.Type                     = 'tree';
inputsTree.Graphical                = true;
inputsTree.TreeItems                = items;
inputsTree.TreeMultiSelect          = 1;
inputsTree.UserData                 = handles;
inputsTree.RowSpan                  = [1 4];
inputsTree.ColSpan                  = [1 1];
inputsTree.MinimumSize              = [200 200];
inputsTree.Tag                      = 'inputsTree';
inputsTree.MatlabMethod             = 'busSelectorddg_cb';
inputsTree.MatlabArgs               = {'%dialog', 'doTreeSelection', '%tag'};

findButton.Name                     = DAStudio.message('Simulink:dialog:BusSelectorFind');
findButton.Type                     = 'pushbutton';
findButton.RowSpan                  = [1 1];
findButton.ColSpan                  = [2 2];
findButton.Enabled                  = 0;
findButton.Tag                      = 'findButton';
findButton.MatlabMethod             = 'busSelectorddg_cb';
findButton.MatlabArgs               = {'%dialog', 'doFind'};

selectButton.Name                   = DAStudio.message('Simulink:dialog:BusSelectorSelect');
selectButton.Type                   = 'pushbutton';
selectButton.RowSpan                = [2 2];
selectButton.ColSpan                = [2 2];
selectButton.Enabled                = 0;
selectButton.Tag                    = 'selectButton';
selectButton.MatlabMethod           = 'busSelectorddg_cb';
selectButton.MatlabArgs             = {'%dialog', 'doSelect'};

refreshButton.Name                  = DAStudio.message('Simulink:dialog:BusSelectorRefresh');
refreshButton.Type                  = 'pushbutton';
refreshButton.RowSpan               = [3 3];
refreshButton.ColSpan               = [2 2];
refreshButton.Tag                   = 'refreshButton';
refreshButton.MatlabMethod          = 'busSelectorddg_cb';
refreshButton.MatlabArgs            = {'%dialog', 'unhilite', true};

inputGroup.Name                     = '';
inputGroup.Type                     = 'panel';
inputGroup.Items                    = {inputsTree, findButton, selectButton, refreshButton};
inputGroup.LayoutGrid               = [4 2];
inputGroup.RowStretch               = [0 0 0 1];
inputGroup.RowSpan                  = [1 1];
inputGroup.ColSpan                  = [1 1];

% Output Group -------------------------
entries = busSelectorddg_cb([], 'validate', block, source.state.OutputSignals);
outputsList.Name                    = DAStudio.message('Simulink:dialog:BusSelectorOutputList');
outputsList.Type                    = 'listbox';
outputsList.MultiSelect             = 1;
outputsList.Entries                 = entries;
outputsList.UserData                = outputsList.Entries;
outputsList.RowSpan                 = [1 4];
outputsList.ColSpan                 = [1 1];
outputsList.MinimumSize             = [200 200];
outputsList.Tag                     = 'outputsList';
outputsList.MatlabMethod            = 'busSelectorddg_cb';
outputsList.MatlabArgs              = {'%dialog', 'doListSelection', '%tag'};
outputsList.ListKeyPressCallback    = @listKeyPressCB;

outputCheck.Name                    = DAStudio.message('Simulink:dialog:BusSelectorMuxOut');
outputCheck.Type                    = 'checkbox';
outputCheck.RowSpan                 = [5 5];
outputCheck.ColSpan                 = [1 2];
outputCheck.ObjectProperty          = 'OutputAsBus';
outputCheck.Tag                     = outputCheck.ObjectProperty;
% required for synchronization --------
outputCheck.MatlabMethod            = 'slDialogUtil';
outputCheck.MatlabArgs              = {source, 'sync', '%dialog', 'checkbox', '%tag'};

upButton.Name                       = DAStudio.message('Simulink:dialog:BusSelectorUp');
upButton.Type                       = 'pushbutton';
upButton.RowSpan                    = [1 1];
upButton.ColSpan                    = [2 2];
upButton.Enabled                    = 0;
upButton.Tag                        = 'upButton';
upButton.MatlabMethod               = 'busSelectorddg_cb';
upButton.MatlabArgs                 = {'%dialog', 'doUp'};

downButton.Name                     = DAStudio.message('Simulink:dialog:BusSelectorDown');
downButton.Type                     = 'pushbutton';
downButton.RowSpan                  = [2 2];
downButton.ColSpan                  = [2 2];
downButton.Enabled                  = 0;
downButton.Tag                      = 'downButton';
downButton.MatlabMethod             = 'busSelectorddg_cb';
downButton.MatlabArgs               = {'%dialog', 'doDown'};

removeButton.Name                   = DAStudio.message('Simulink:dialog:BusSelectorRemove');
removeButton.Type                   = 'pushbutton';
removeButton.RowSpan                = [3 3];
removeButton.ColSpan                = [2 2];
removeButton.Enabled                = 0;
removeButton.Tag                    = 'removeButton';
removeButton.MatlabMethod           = 'busSelectorddg_cb';
removeButton.MatlabArgs             = {'%dialog', 'doRemove'};

outputGroup.Name                    = '';
outputGroup.Type                    = 'panel';
outputGroup.Items                   = {outputsList, upButton, downButton, removeButton, outputCheck};
outputGroup.LayoutGrid              = [5 2];
outputGroup.RowStretch              = [0 0 0 1 0];
outputGroup.RowSpan                 = [1 1];
outputGroup.ColSpan                 = [2 2];

% Invisible widget mapping to OutputSignals object property
outputsInvisible.Name               = 'OutputSignals';
outputsInvisible.Type               = 'edit';
outputsInvisible.Value              = source.state.OutputSignals;
outputsInvisible.Visible            = 0;
outputsInvisible.RowSpan            = [2 2];
outputsInvisible.ColSpan            = [1 2];
outputsInvisible.ObjectProperty     = 'OutputSignals';
outputsInvisible.Tag                = outputsInvisible.ObjectProperty;

paramGroup.Name                     = 'Parameters';
paramGroup.Type                     = 'group';
paramGroup.Items                    = {inputGroup, outputGroup, outputsInvisible};
paramGroup.LayoutGrid               = [2 2];
paramGroup.RowStretch               = [1 0];
paramGroup.ColStretch               = [1 1];
paramGroup.RowSpan                  = [2 2];
paramGroup.ColSpan                  = [1 1];
paramGroup.Source                   = block;

%-----------------------------------------------------------------------
% Assemble main dialog struct
%-----------------------------------------------------------------------
isLibraryLink = ~strcmp(get_param(bdroot(block.Handle),'Lock'), 'on') && ...
                ~strcmp(get_param(block.Handle, 'LinkStatus'), 'none');
title   = ['Block Parameters: ' strrep(block.Name, sprintf('\n'), ' ')];
disable = block.isHierarchySimulating || isLibraryLink;
dlgStruct.DialogTitle               = title;
dlgStruct.DialogTag                 = 'BusSelector';
dlgStruct.Items                     = {descGroup, paramGroup};
dlgStruct.LayoutGrid                = [2 1];
dlgStruct.RowStretch                = [0 1];
dlgStruct.DisableDialog             = disable;
dlgStruct.CloseCallback             = 'busSelectorddg_cb';
dlgStruct.CloseArgs                 = {'%dialog', 'doClose'};
dlgStruct.HelpMethod                = 'slhelp';
dlgStruct.HelpArgs                  = {block.Handle};
% Required for simulink/block sync ----
dlgStruct.PreApplyCallback          = 'busSelectorddg_cb';
dlgStruct.PreApplyArgs              = {'%dialog', 'doPreApply'};
% Required for deregistration ---------
dlgStruct.CloseMethod               = 'closeCallback';
dlgStruct.CloseMethodArgs           = {'%dialog'};
dlgStruct.CloseMethodArgsDT         = {'handle'};


% ----------------------------------------------------------------------
% callback for bus selector list box
function listKeyPressCB(dlg, tag, key) %#ok
if strcmpi(key, 'del')
    busSelectorddg_cb(dlg, 'doRemove');
end
