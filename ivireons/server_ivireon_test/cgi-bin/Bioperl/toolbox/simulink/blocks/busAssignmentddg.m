function dlgStruct = busAssignmentddg(source, block)

% Copyright 2003-2010 The MathWorks, Inc.

% Getting the BusStruct and InputSignals is expensive so get it now and 
% cache it in the block's UserData
if  ~isfield(block.UserData, 'flag') && ~block.isHierarchyReadonly
    ud.oldUserData = block.UserData;
    
    modelHandle = busAssignmentddg_cb([], 'getModelHandleFromBlock',block);
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
[items handles] = busAssignmentddg_cb([], 'getTreeItems', block);
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
inputsTree.MatlabMethod             = 'busAssignmentddg_cb';
inputsTree.MatlabArgs               = {'%dialog', 'doTreeSelection', '%tag'};

findButton.Name                     = DAStudio.message('Simulink:dialog:BusSelectorFind');
findButton.Type                     = 'pushbutton';
findButton.RowSpan                  = [1 1];
findButton.ColSpan                  = [2 2];
findButton.Enabled                  = 0;
findButton.Tag                      = 'findButton';
findButton.MatlabMethod             = 'busAssignmentddg_cb';
findButton.MatlabArgs               = {'%dialog', 'doFind'};

selectButton.Name                   = DAStudio.message('Simulink:dialog:BusSelectorSelect');
selectButton.Type                   = 'pushbutton';
selectButton.RowSpan                = [2 2];
selectButton.ColSpan                = [2 2];
selectButton.Enabled                = 0;
selectButton.Tag                    = 'selectButton';
selectButton.MatlabMethod           = 'busAssignmentddg_cb';
selectButton.MatlabArgs             = {'%dialog', 'doSelect'};

refreshButton.Name                  = DAStudio.message('Simulink:dialog:BusSelectorRefresh');
refreshButton.Type                  = 'pushbutton';
refreshButton.RowSpan               = [3 3];
refreshButton.ColSpan               = [2 2];
refreshButton.Tag                   = 'refreshButton';
refreshButton.MatlabMethod          = 'busAssignmentddg_cb';
refreshButton.MatlabArgs            = {'%dialog', 'unhilite', true};

inputGroup.Name                     = '';
inputGroup.Type                     = 'panel';
inputGroup.Items                    = {inputsTree, findButton, refreshButton, selectButton};
inputGroup.LayoutGrid               = [4 2];
inputGroup.RowStretch               = [0 0 0 1];
inputGroup.RowSpan                  = [1 1];
inputGroup.ColSpan                  = [1 1];

% Output Group -------------------------
entries = busAssignmentddg_cb([], 'validate', block, source.state.AssignedSignals);
assignedList.Name                   = DAStudio.message('Simulink:dialog:BusAssignmentAssignedList');
assignedList.Type                   = 'listbox';
assignedList.MultiSelect            = 1;
assignedList.Entries                = entries;
assignedList.UserData               = assignedList.Entries;
assignedList.RowSpan                = [1 4];
assignedList.ColSpan                = [1 1];
assignedList.MinimumSize            = [200 200];
assignedList.Tag                    = 'assignedList';
assignedList.MatlabMethod           = 'busAssignmentddg_cb';
assignedList.MatlabArgs             = {'%dialog', 'doListSelection', '%tag'};
assignedList.ListKeyPressCallback   = @listKeyPressCB;

upButton.Name                       = DAStudio.message('Simulink:dialog:BusSelectorUp');
upButton.Type                       = 'pushbutton';
upButton.RowSpan                    = [1 1];
upButton.ColSpan                    = [2 2];
upButton.Enabled                    = 0;
upButton.Tag                        = 'upButton';
upButton.MatlabMethod               = 'busAssignmentddg_cb';
upButton.MatlabArgs                 = {'%dialog', 'doUp'};

downButton.Name                     = DAStudio.message('Simulink:dialog:BusSelectorDown');
downButton.Type                     = 'pushbutton';
downButton.RowSpan                  = [2 2];
downButton.ColSpan                  = [2 2];
downButton.Enabled                  = 0;
downButton.Tag                      = 'downButton';
downButton.MatlabMethod             = 'busAssignmentddg_cb';
downButton.MatlabArgs               = {'%dialog', 'doDown'};

removeButton.Name                   = DAStudio.message('Simulink:dialog:BusSelectorRemove');
removeButton.Type                   = 'pushbutton';
removeButton.RowSpan                = [3 3];
removeButton.ColSpan                = [2 2];
removeButton.Enabled                = 0;
removeButton.Tag                    = 'removeButton';
removeButton.MatlabMethod           = 'busAssignmentddg_cb';
removeButton.MatlabArgs             = {'%dialog', 'doRemove'};

outputGroup.Name                    = '';
outputGroup.Type                    = 'panel';
outputGroup.Items                   = {upButton, downButton, removeButton, assignedList};
outputGroup.LayoutGrid              = [5 2];
outputGroup.RowStretch              = [0 0 0 1 0];
outputGroup.RowSpan                 = [1 1];
outputGroup.ColSpan                 = [2 2];

% Invisible widget mapping to AssignedSignals object property
assignedInvisible.Name              = 'AssignedSignals';
assignedInvisible.Type              = 'edit';
assignedInvisible.Value             = source.state.AssignedSignals;
assignedInvisible.Visible           = 0;
assignedInvisible.RowSpan           = [2 2];
assignedInvisible.ColSpan           = [1 2];
assignedInvisible.ObjectProperty    = 'AssignedSignals';
assignedInvisible.Tag               = assignedInvisible.ObjectProperty;

paramGroup.Name                     = 'Parameters';
paramGroup.Type                     = 'group';
paramGroup.Items                    = {inputGroup, outputGroup, assignedInvisible};
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
dlgStruct.DialogTag                 = 'BusAssignment';
dlgStruct.Items                     = {descGroup, paramGroup};
dlgStruct.LayoutGrid                = [2 1];
dlgStruct.RowStretch                = [0 1];
dlgStruct.DisableDialog             = disable;
dlgStruct.CloseCallback             = 'busAssignmentddg_cb';
dlgStruct.CloseArgs                 = {'%dialog', 'doClose'};
dlgStruct.HelpMethod                = 'slhelp';
dlgStruct.HelpArgs                  = {block.Handle};
% Required for simulink/block sync ----
dlgStruct.PreApplyCallback          = 'busAssignmentddg_cb';
dlgStruct.PreApplyArgs              = {'%dialog', 'doPreApply'};
% Required for deregistration ---------
dlgStruct.CloseMethod               = 'closeCallback';
dlgStruct.CloseMethodArgs           = {'%dialog'};
dlgStruct.CloseMethodArgsDT         = {'handle'};


% ----------------------------------------------------------------------
% callback for bus assignment list box
function listKeyPressCB(dlg, tag, key) %#ok
if strcmpi(key, 'del')
    busAssignmentddg_cb(dlg, 'doRemove');
end
