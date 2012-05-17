function dlgStruct = subsysVariantsddg(source, h)

% Copyright 2009-2010 The MathWorks, Inc.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Top group is the block description %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    descTxt.Name     = DAStudio.message('Simulink:dialog:SubsystemVariantDescription');
    descTxt.Type     = 'text';
    descTxt.WordWrap = true;

    descGrp.Name     = 'Variant Subsystem';
    descGrp.Type     = 'group';
    descGrp.Items    = {descTxt};
    descGrp.RowSpan  = [1 1];
    descGrp.ColSpan  = [1 1];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Bottom group is the block parameters %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get the variants for the Model Reference block
    variantsPanel = i_GetVariantsPanel(source, h);

    paramGrp.Type       = 'panel';
    paramGrp.LayoutGrid = [1 1];
    paramGrp.Items      = {variantsPanel};
    paramGrp.RowSpan    = [2 2];
    paramGrp.ColSpan    = [1 1];
    paramGrp.Source     = h;

    %-----------------------------------------------------------------------
    % Assemble main dialog struct
    %-----------------------------------------------------------------------
    dlgStruct.DialogTitle   = ['Block Parameters: ' strrep(h.Name, sprintf('\n'), ' ')];
    dlgStruct.DialogTag     = 'Subsystem';
    dlgStruct.Items         = {descGrp, paramGrp};
    dlgStruct.LayoutGrid    = [2 1];
    dlgStruct.RowStretch    = [0 1];

    % For Block Help
    dlgStruct.HelpMethod    = 'slhelp';
    dlgStruct.HelpArgs      = {h.Handle};

    % Required for simulink/block sync ----
    dlgStruct.PreApplyCallback  = 'subsysVariantsddg_cb';
    dlgStruct.PreApplyArgs      = {'doPreApply', '%dialog'};
    dlgStruct.CloseCallback     = 'subsysVariantsddg_cb';
    dlgStruct.CloseArgs         = {'doClose', '%dialog'};

    % Required for deregistration ---------
    dlgStruct.CloseMethod       = 'closeCallback';
    dlgStruct.CloseMethodArgs   = {'%dialog'};
    dlgStruct.CloseMethodArgsDT = {'handle'};

    % Enable dialog
    [~, isLocked] = source.isLibraryBlock(h);
    if isLocked
        dlgStruct.DisableDialog = 1;
    else
        dlgStruct.DisableDialog = 0;
    end
end

%===============================================================================
function variantsPanel = i_GetVariantsPanel(source, h)

    ls = h.StaticLinkStatus;
    readOnly = strcmp(ls, 'resolved') || strcmp(ls, 'implicit');

    %% Add Variants button
    pAdd.Name                = '';
    pAdd.Type                = 'pushbutton';
    pAdd.RowSpan             = [1 1];
    pAdd.ColSpan             = [1 1];
    pAdd.Enabled             = ~readOnly;
    pAdd.FilePath            = fullfile(matlabroot,'toolbox/shared/simulink/resources/AddSubsystemVariant.png');
    pAdd.ToolTip             = DAStudio.message('Simulink:dialog:SubsystemAddVariantTip');
    pAdd.Tag                 = 'AddButton';
    pAdd.MatlabMethod        = 'subsysVariantsddg_cb';
    pAdd.MatlabArgs          = {'doAdd', '%dialog'};

    %% Edit variants object button
    pEdit.Name               = '';
    pEdit.Type               = 'pushbutton';
    pEdit.RowSpan            = [2 2];
    pEdit.ColSpan            = [1 1];
    pEdit.Enabled            = 1;
    pEdit.FilePath           = fullfile(matlabroot,'toolbox/shared/simulink/resources/EditVariantObject.png');
    pEdit.ToolTip            = DAStudio.message('Simulink:dialog:SubsystemEditVariantObjectTip');
    pEdit.Tag                = 'EditButton';
    pEdit.MatlabMethod       = 'subsysVariantsddg_cb';
    pEdit.MatlabArgs         = {'doEdit', '%dialog'};

    %% Open Variants button
    pOpen.Name               = '';
    pOpen.Type               = 'pushbutton';
    pOpen.RowSpan            = [3 3];
    pOpen.ColSpan            = [1 1];
    pOpen.Enabled            = 1;
    pOpen.FilePath           = fullfile(matlabroot,'toolbox/shared/simulink/resources/OpenSubsystem.png');
    pOpen.ToolTip            = DAStudio.message('Simulink:dialog:SubsystemOpenVariantTip');
    pOpen.Tag                = 'OpenButton';
    pOpen.MatlabMethod       = 'subsysVariantsddg_cb';
    pOpen.MatlabArgs         = {'doOpen', '%dialog'};

    %% Refresh button
    pRefresh.Name            = '';
    pRefresh.Type            = 'pushbutton';
    pRefresh.RowSpan         = [4 4];
    pRefresh.ColSpan         = [1 1];
    pRefresh.Enabled         = 1;
    pRefresh.FilePath        = fullfile(matlabroot,'toolbox/simulink/blocks/refresh.bmp'); 
    pRefresh.ToolTip         = DAStudio.message('Simulink:dialog:SubsystemRefreshVariantTip');
    pRefresh.Tag             = 'RefreshButton';
    pRefresh.MatlabMethod    = 'subsysVariantsddg_cb';
    pRefresh.MatlabArgs      = {'doRefresh', '%dialog'};

    %% Spacer
    spacer1.Name             = '';
    spacer1.Type             = 'text';
    spacer1.RowSpan          = [5 5];
    spacer1.ColSpan          = [1 1];

    panel1.Type          = 'panel';
    panel1.Items         = {pAdd, pEdit, pOpen, pRefresh, spacer1};
    panel1.LayoutGrid    = [5 1];
    panel1.RowStretch    = [0 0 0 0 1];
    panel1.RowSpan       = [1 1];
    panel1.ColSpan       = [1 1];

    %% Table of Subsystem Variants
    if isempty(source.UserData)
        tableData = subsysVariantsddg_cb('getVariantsData', h.Handle);
        
        % Cache this in myData
        myData.TableData = tableData;

        % Setup override variant
        myData.OverrideVariant = h.OverrideUsingVariant;
        
    else
        % Retrieve data
        myData    = source.UserData;
        tableData = myData.TableData;
    end

    % Setup entries
    if isempty(tableData)
        myData.Entries = {};
    else
        entries = tableData(:, 3);
        entries(strcmp(entries, '')) = []; % Remove empty
        entries(strncmp(entries, '%', 1)) = []; % Remove commented       
        myData.Entries = entries;
    end
    rows = size(tableData, 1);

    % Cache in userdata
    source.UserData = myData;
    
    pTable.Name          = '';
    pTable.Type          = 'table';
    pTable.Size          = [rows 3];
    pTable.Data          = tableData(:, 2:4);
    pTable.Grid          = 1;
    pTable.ColHeader     = {DAStudio.message('Simulink:dialog:SubsystemVarTableCol0'), ...
                        DAStudio.message('Simulink:dialog:SubsystemVarTableCol1'), ...
                        DAStudio.message('Simulink:dialog:SubsystemVarTableCol2'), ...
                   };
    pTable.HeaderVisibility     = [0 1];
    pTable.ColumnCharacterWidth = [15 15 15];
    pTable.RowSpan              = [1 1];
    pTable.ColSpan              = [2 2];
    pTable.Enabled              = ~readOnly;
    pTable.Editable             = 1;
    pTable.ReadOnlyColumns      = [0 2];
    pTable.SelectionBehavior    = 'Row';
    pTable.MinimumSize          = [350 150];
    pTable.LastColumnStretchable= 1;
    pTable.Tag                  = 'VariantsTable';
    pTable.ValueChangedCallback = @i_TableValueChanged;


    tableGrp.Name        = DAStudio.message('Simulink:dialog:SubsystemVarChoices');
    tableGrp.Type        = 'group';
    tableGrp.LayoutGrid  = [1 2];
    tableGrp.ColStretch  = [0 1];
    tableGrp.ColSpan     = [1 1];
    tableGrp.RowSpan     = [1 1];
    tableGrp.Items       = {panel1, pTable};


    %  --------- variant override ----------
    %  |
    %  |  [x] Override variant conditions and use following
    %  |  Variant: NAME-pulldown
    % 
    %  set_param(blk,'OverrideUsingVariant','')
    %  set_param(blk,'OverrideUsingVariant','name')
    pOverrideCheckbox.Name         = DAStudio.message('Simulink:dialog:ModelRefOverrideVariant');
    pOverrideCheckbox.Type         = 'checkbox';
    pOverrideCheckbox.Tag          = 'OverrideVariantCheckbox';
    pOverrideCheckbox.Value        = ~isempty(myData.OverrideVariant);
    pOverrideCheckbox.ToolTip      = DAStudio.message('Simulink:dialog:ModelRefOverrideVariantTip');
    pOverrideCheckbox.MatlabMethod = 'subsysVariantsddg_cb';
    pOverrideCheckbox.MatlabArgs   = {'doOverrideCheckbox', '%dialog'};

    % Override combobox and active variant
    idx = find(strcmp(myData.Entries, myData.OverrideVariant));
    if isempty(idx)
        idx = 0;
    else
        idx = idx(1); %in case multiple same named variant
        idx = idx - 1; %0 based
    end

    pOverride.Name          = DAStudio.message('Simulink:dialog:ModelRefOverrideVariantCombo');
    pOverride.Type          = 'combobox';
    pOverride.Tag           = 'OverrideVariantCombo';
    pOverride.Entries       = myData.Entries;    
    pOverride.Value         = idx;
    pOverride.Enabled       = ~isempty(myData.OverrideVariant);
    pOverride.ToolTip       = DAStudio.message('Simulink:dialog:ModelRefOverrideVariantTip');
    pOverride.MatlabMethod  = 'subsysVariantsddg_cb';
    pOverride.MatlabArgs    = {'doOverride', '%dialog'};

    pOverrideGrp.Name       = '';
    pOverrideGrp.Type       = 'panel';
    pOverrideGrp.LayoutGrid = [2 1];
    pOverrideGrp.Items      = {pOverrideCheckbox, pOverride};
    pOverrideGrp.ColSpan    = [1 1];
    pOverrideGrp.RowSpan    = [1 1];

    %% Code generation check box
    pCode                 = ...
        i_GetProperty(source, h, 'GeneratePreprocessorConditionals');
    pCode.Name            = ...
        DAStudio.message('Simulink:dialog:ModelRefGenPreConditionals');
    pCode.Value           = h.GeneratePreprocessorConditionals;
    pCode.Enabled         = isempty(myData.OverrideVariant) && ...
        subsysVariantsddg_cb('IsGenerateCodeEnabled', h.Handle);
    pCode.ToolTip         = ...
        DAStudio.message('Simulink:dialog:ModelRefGenPreConditionalsTip');

    pCodeGrp.Name         = ...
        DAStudio.message('Simulink:dialog:ModelRefCodeGeneration');
    pCodeGrp.Type         = 'group';
    pCodeGrp.LayoutGrid   = [1 1];
    pCodeGrp.Items        = {pCode};
    pCodeGrp.ColSpan      = [2 2];
    pCodeGrp.RowSpan      = [1 1];


    %% Create bottom panel
    botPanel.Name       = '';
    botPanel.Type       = 'panel';
    botPanel.LayoutGrid = [1 2];
    botPanel.ColSpan    = [1 1];
    botPanel.RowSpan    = [2 2];
    botPanel.Items      = {pOverrideGrp, pCodeGrp};

    variantsPanel.Name       = '';
    variantsPanel.Type       = 'panel';
    variantsPanel.LayoutGrid = [2 1];
    variantsPanel.Items      = {tableGrp, botPanel};

    %Setup the userdata
    source.UserData = myData;
end

%===============================================================================
function property = i_GetProperty(source, h, propName)
% Get relevant property information for requested property

% The ObjectProperty and the Tag are mostly the same.
    property.ObjectProperty = propName;
    property.Tag            = propName;

    % Choose the proper dialog parameter type.
    switch lower(h.IntrinsicDialogParameters.(propName).Type)
      case 'boolean'
        property.Type         = 'checkbox';
        property.MatlabMethod = 'handleCheckEvent';
      otherwise
        error('assert - invalid type');
    end
    property.MatlabArgs = {source, '%value', ...
                        find(strcmp(source.paramsMap, propName))-1, '%dialog'};
end


%==========================================================================
function i_TableValueChanged(dialogH, row, ~, newVal)

% React to change in table value
% col must be 2 - variant object name only
    source = dialogH.getSource;
    myData = source.UserData;
    data = myData.TableData;

    % Update user data
    data{row+1, 3} = newVal;

    % Update condition column
    try
        condValue = evalin('base', [newVal, '.Condition']);
    catch %#ok
        if isempty(newVal) || newVal(1) == '%'
            condValue = DAStudio.message('Simulink:dialog:InactiveVariantObject');
        else
            condValue = DAStudio.message('Simulink:dialog:NoVariantObject');
        end
    end
    data{row+1, 4} = condValue;

    myData.TableData = data;
    source.UserData = myData;

    % Name has changed, so update combobox choices
    dialogH.refresh;
end

% LocalWords:  dlg Txt Grp cb deregistration DT xxxp userdata wid bmp
