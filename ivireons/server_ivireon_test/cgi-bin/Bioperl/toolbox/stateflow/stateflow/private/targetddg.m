function ddg = targetddg(h, name)
% Target dialog schema code.

% Copyright 2002-2008 The MathWorks, Inc.

if(strcmp(name,'tab'))
    ddg.Name = h.Name;
    ddg.Items = {mainPanel(h)};
else
    ddg.DialogTitle      = [ title(h) ': ' h.Machine.Name '/' h.Name];
    ddg.Items            = {mainPanel(h)};
    ddg.DialogTag        = create_unique_dialog_tag(h);
    ddg.SmartApply       = true;
    ddg.CloseCallback    = 'sf';
    ddg.CloseArgs        = {'Private', 'targetddg_preclose_callback', '%dialog'};
    ddg.PreApplyCallback = 'sf';
    ddg.PreApplyArgs     = {'Private', 'targetddg_preapply_callback', '%dialog'};
end

ddg.HelpMethod = 'sfhelp';

tk = targetKind(h);
if tk.isSFUN
    ddg.HelpArgs = {h,'simulation_target_dialog'};
elseif tk.isRTW
    ddg.HelpArgs = {h,'rtw_target_dialog'};
else
    ddg.HelpArgs = {h,'custom_target_dialog'};
end

ddg.DisableDialog = ~is_object_editable(h);

end %targetddg

function D = mainPanel(h)
D.Type       = 'panel';
D.Tag        = 'sfTargetdlg_mainPanel';

layout = ...
    {
    subTitleGroup(h)
    mainTabs(h)
    };

D = layoutItems(D,layout);

end

function D = subTitleGroup(h)
    Dtext = subTitleText(h);
    if isequal(Dtext,stop)
        D = Dtext;
        return;
    end
    
    D.Type = 'group';
    D.Name = title(h);
    D.Items = {Dtext};
    
end

function D = subTitleText(h)
    st = subtitle(h);
    if isempty(st)
        D = stop;
    else
    D.Type = 'text';
    D.Name = st;
    D.WordWrap = true;
    end
end

function D = mainTabs(h)

D.Type = 'tab';
D.Tag = 'sfTargetDlg_mainTab';
D.Tabs = { generalTab(h), customCodeTab(h), descriptionTab(h) };

end

function D = generalTab(h)
D.Name = '&General';
D.Tag  = 'sfTargetdlg_generalTab';

layout = ...
    { nameLabel() nameEdit(h)
%    parentLabel(h)         parentHyper(h)
    targetLanguageLabel() targetLanguageText(h)
    stop stop
    coderGroup(h) stretch
    stop stop
    buildGroup(h) stretch
    stop stop
    };
D.RowStretch = [0 0 1 0 1 0 10];

D = layoutItems(D,layout);
D.ColStretch = [0 1];
end

function D = useLocalCustomCodeCheck(h)

if ~h.Machine.isLibrary()
    D = stop;
    return;
end

D.Name           = 'Use local custom code settings (do not inherit from main model)';
D.Type           = 'checkbox';
D.ObjectProperty = 'UseLocalCustomCodeSettings';
D.Tag            = 'sfTargetdlg_local_settings';

end

function D = applyToAllLibsCheck(h)

if h.Machine.isLibrary()
    D = stop;
    return;
end

D.Name           = 'Use these custom code settings for all libraries';
D.Type           = 'checkbox';
D.ObjectProperty = 'ApplyToAllLibs';
D.Tag            = 'sfTargetdlg_settings_for_all_libraries';

end

function D = coderGroup(h)

D.Name = 'Code Generation Options';
D.Type = 'group';
D.Tag = 'sfTargetdlg_coderGroupTag';

% Generate the dialog from the flag info on the target
flags = target_methods('codeflags',h.Id);
layout = cell(numel(flags),1);

% for each supported flag, create the widget struct
for i = 1:length(flags)
    flag     = flags(i);

    val = flag.value;
    if(val == -1)
        val = flag.defaultValue;
    end

    wid.Name = flag.description;

    switch(flag.type)
        case 'boolean'
            wid.Type = 'checkbox';
        case 'enumeration'
            wid.Type = 'combobox';
            wid.Entries = flag.values;
        case 'word'
            wid.Type = 'edit';
    end

    wid.Value           = val;
    wid.Tag             = int2str(i);
    wid.Enabled         = strcmp(flag.enable, 'on');
    layout{i}          = wid;
end

D.Tag        = strcat('sfCoderoptsdlg_', D.Name);
D = layoutItems(D,layout);

end

function D = customCodeTab(h)
% TODO: This is really ugly because of the nested tab. May be better to go bag to
% original separete dialog.
D.Name = '&Custom Code';
D.Tag = 'sfTargetdlg_CustomCodeTag';
  %-------------------------
  % Tab items
  %-------------------------
  item1.Name           = 'Custom code included at the top of generated code (e.g. #include''s)';
  item1.Type           = 'editarea';  
  item1.ObjectProperty = 'CustomCode';
  item1.Tag = strcat('sfTargetoptsdlg_', item1.Name);
  
  item2.Name           = 'Space-separated list of custom include directories';
  item2.Type           = 'editarea';
  item2.ObjectProperty = 'UserIncludeDirs';
  item2.Tag = strcat('sfTargetoptsdlg_', item2.Name);
  
  item3.Name           = 'Custom source files';
  item3.Type           = 'editarea';  
  item3.ObjectProperty = 'UserSources';
  item3.Tag = strcat('sfTargetoptsdlg_', item3.Name);
  
  item4.Name           = 'Custom libraries';
  item4.Type           = 'editarea';
  item4.ObjectProperty = 'UserLibraries';
  item4.Tag = strcat('sfTargetoptsdlg_', item4.Name);
  
  item5.Name           = 'Code generation directory';
  item5.Type           = 'editarea';
  item5.ObjectProperty = 'CodegenDirectory';
  item5.Tag = strcat('sfTargetoptsdlg_', item5.Name);
  
  item6.Name           = 'Custom initialization code (called from mdlInitialize)';
  item6.Type           = 'editarea';
  item6.ObjectProperty = 'CustomInitializer';
  item6.Tag            = strcat('sfTargetoptsdlg_', item6.Name);
   
  item7.Name           = 'Custom termination code (called from mdlTerminate)';
  item7.Type           = 'editarea';
  item7.ObjectProperty = 'CustomTerminator';
  item7.Tag            = strcat('sfTargetoptsdlg_', item7.Name);
  
  item8.Name           = 'Reserved names';
  item8.Type           = 'editarea';
  item8.ObjectProperty = 'ReservedNames';
  item8.Tag            = strcat('sfTargetoptsdlg_', item8.Name);
  
  %-------------------------
  % Tab panels
  %-------------------------
  tab1.Name = 'Include Code';
  tab1.Items = {item1};
  %tab1.Tag = 'real';
  
  tab2.Name = 'Include Paths';
  tab2.Items = {item2};
  %tab2.Tag = strcat('sfTargetoptsdlg_', tab2.Name);
  
  tab3.Name = 'Source Files';
  tab3.Items = {item3};
  %tab3.Tag = strcat('sfTargetoptsdlg_', tab3.Name);
  
  tab4.Name = 'Libraries';
  tab4.Items = {item4};
  %tab4.Tag = strcat('sfTargetoptsdlg_', tab4.Name);
  
  tab5.Name = 'Generated Code Directory';
  tab5.Items = {item5};
  %tab5.Tag = strcat('sfTargetoptsdlg_', tab5.Name);
  
  tab6.Name  = 'Initialization Code';
  tab6.Items = {item6};
  
  tab7.Name  = 'Termination Code';
  tab7.Items = {item7};

  tab8.Name  = 'Reserved Names';
  tab8.Items = {item8};

  %-------------------------
  % Tab
  %-------------------------
  tabMain.Name = 'tabContainer';
  tabMain.Type = 'tab';
  tk = targetKind(h);
  
  if tk.isRTW || tk.isSFUN
    tabMain.Tabs    = {tab1, tab2, tab3, tab4, tab6, tab7, tab8}; 
  else
    tabMain.Tabs = {tab1, tab2, tab3, tab4, tab5, tab8};
  end
  tabMain.Tag = strcat('sfTargetoptsdlg_', tabMain.Name);
  %tabMain.TabPosition = false;
    
  layout = ...
      {stop
      tabMain
      useLocalCustomCodeCheck(h)
      applyToAllLibsCheck(h)
      };
   D = layoutItems(D,layout);
   D.RowStretch = [0 1 0 0];
   
end

function D = buildGroup(h)
D.Name = 'Build Actions';
D.Type = 'group';
tc = targetCombo(h);
tb = targetBuildButton(h);
layout = { tc tb };

D = layoutItems(D,layout);
D.ColStretch = [1 0];
end

function D = targetCombo(h)

D.Type          = 'combobox';
D.MultiSelect = false;
D.Graphical = true;
D.Tag           = 'sfTargetdlg_targetComboTag';
%populate the entries based on the targetmethods buildCommand
D.Entries       = get_build_combo_string_l(h.Id);
D.Value = 0;
% figure out the current selection of the combobox
thisDialog = findDialog(h);
if ~isempty(thisDialog)
    D.Value = thisDialog.getWidgetValue('sfTargetdlg_targetComboTag');
end

end

function D = targetBuildButton(h)

D.Name          = 'Execute';
D.Type          = 'pushbutton';
D.Tag           = 'sfTargetdlg_btnBuildTag';
D.Alignment     = 7;
D.MatlabMethod  = 'sf';
D.MatlabArgs    = {'Private','target_build_button_cb','%source', '%dialog'};
end

%------------------------------------------------------------------
% Gets the combobox entry from target_methods('buildCommands', id)
%------------------------------------------------------------------
function entries = get_build_combo_string_l(targetId)
buildCommands = target_methods('buildCommands', targetId);
entries       = {buildCommands{:,1}};

end

function D = descriptionTab(h)

D.Name = '&Description';

layout = ...
    { descriptionEdit(h) stretch
      docHyper(h)        docEdit(h) 
    };

D.RowStretch = [1 0];
D.ColStretch = [0 1];
D = layoutItems(D,layout);

end

function D = docHyper(h)
D.Name           = [commonMessage('DocumentLink') ':'];
D.Type           = 'hyperlink';
D.Tag            = 'sfTargetdlg_docLinkNameTag';
D.MatlabMethod   = 'sf';
D.MatlabArgs     = {'Private', 'dlg_goto_document', h.Id};
end

function D = docEdit(h)
%Document link edit area

D.Name           = '';
D.Type           = 'edit';
D.ObjectProperty = 'Document';
D.Tag            = 'sfTargetdlg_DocLinkEdit';
end

function D = descriptionEdit(h)

D.Name           = 'Description';
D.Type           = 'editarea';
D.WordWrap       = true;
D.ObjectProperty = 'Description';
D.Tag            = 'sfTargetdlg_Description';
end

function D = nameLabel()
D.Name = 'Name:';
D.Type = 'text';
end

function D = nameEdit(h)
D.Name             = '';
D.Type             = 'edit';
D.ObjectProperty   = 'Name';
D.Tag              = 'sfTargetdlg_Name';
D.Enabled          = ~h.isReadonlyProperty('Name');
end

% function D = parentLabel(h)
% D.Name = 'Parent:';
% D.Type = 'text';
% D.Tag  = strcat('sfTargetdlg_', D.Name);
% end
% 
% function D = parentHyper(h)
% D.Name         = ddg_get_parent_name(h.getParent);
% D.Type         = 'hyperlink';
% D.MatlabMethod = 'sf';
% D.Tag          = 'hypParentTag';
% D.MatlabArgs   = {'Private', 'dlg_goto_parent', h.Id};
% end

function D = targetLanguageLabel
D.Name      = 'Language:';
D.Type      = 'text';
D.Tag       = 'sfTargetdlg_Language';
end

function D = targetLanguageText(h)
if strcmp(h.Name, 'hdl')
    D.Name = 'VHDL/Verilog';
else
    D.Name = 'ANSI-C';
end
D.Type     = 'text';
D.Tag      = strcat('sfTargetdlg_', D.Name);
end

function t = title(h)

tk = targetKind(h);

if tk.isRTW
    t = 'RTW Target';
elseif tk.isSFUN
    t = 'Simulation Target';
elseif tk.isHDL
    t = 'HDL Target';
else
    t = 'Stateflow Custom Target';
end

if sf('Feature','Developer')
    id = strcat('#', sf_scalar2str(h.Id));
    t = strcat(t, id);
end

end

function t = subtitle(h)
    tk = targetKind(h);
    if tk.isSFUN
        t = 'Control how simulation code is generated for Embedded MATLAB Function Blocks, Stateflow Charts, Truth Table Blocks, and Attribute Function Blocks in this model.';
    elseif tk.isHDL
        t = 'Control how HDL code is generated from Embedded MATLAB Functions, Stateflow Charts, and Truth Tables in this model.';
    else        
        t = '';
    end
end

function tk = targetKind(h)
tk.isRTW = false;
tk.isSFUN = false;
tk.isHDL = false;
switch(h.Name)
    case 'rtw', tk.isRTW = true;
    case 'sfun', tk.isSFUN = true;
    case 'hdl', tk.isHDL = true;
end

end %targetKind

function thisDialog = findDialog(h)
% If the dialog is already open return it, otherwise return empty.

thisDialogTag = create_unique_dialog_tag(h);
thisDialog = find_existing_dialog(thisDialogTag);

end %findDialog

function D = layoutItems(D,L)
% Layout a panel given a schematic layout in L as a cell array.

[numRows numCols] = size(L);

activeItem = stop;
rowSpan = 0;
colSpan = 0;
Items = {};

    function addActiveItem
        if isequal(activeItem,stop) 
            return;
        end
        activeItem.ColSpan = activeItem.ColSpan + [0 colSpan-1];
        activeItem.RowSpan = activeItem.RowSpan + [0 rowSpan-1];
        Items{end+1} = activeItem;        
        activeItem = stop;
    end

for r = 1:numRows
    for c = 1:numCols
        item = L{r,c};
        if isequal(item,stretch)
            colSpan = colSpan + 1;
        else
            addActiveItem();
            activeItem = item;
            if ~isequal(activeItem, stop)
                activeItem.RowSpan = [r, r];
                activeItem.ColSpan = [c, c];
            end
            colSpan = 1;
            rowSpan = 1;
        end
    end
    addActiveItem();
end

D.LayoutGrid = size(L);
D.Items = Items;
end

function s = stretch
% Use a stretch in a layout to keep filling with the layout element on the
% left.
s = [];
end

function s = stop
% Use a stop to prevent the element on the left from stretching into this
% row.

s = -1;

end

function s = commonMessage(id,varargin)
s = DAStudio.message(['Stateflow:dialog:Common' id],varargin{:});
end

function s = message(id,varargin)
s = DAStudio.message(['Stateflow:dialog:Target' id],varargin{:});
end
