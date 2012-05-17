function schemas = sfgetinterface(itemID, ~)
    
    % Copyright 2005-2010 The MathWorks, Inc.
    
    switch itemID
        case 'ContextMenu'
            schemas = ContextMenu;
            custom1  = cm_get_custom_schemas('Stateflow:PreContextMenu');
            custom2  = cm_get_custom_schemas('Stateflow:ContextMenu');
            schemas = [custom1, {'separator'}, schemas, {'separator'}, custom2];
        case 'MenuBar'
            schemas = MenuBar;
    end
end

% routs menu item calls to private/sfcall
function callback_fcn(~)
    sf('CallBackFcn');
end

% routs menu item calls to private/sfcall
function hg_ui_event_fcn(~)
    sf('HgUiEventFcn');
end

% =========================================================================
% MENU BAR
% =========================================================================
function schemas = MenuBar
    customSchemas = cm_get_custom_schemas('Stateflow:MenuBar');
    
    schemas = {@FileMenu, ...
        @EditMenu, ...
        @ViewMenu, ...
        @SimulationMenu, ...
        @ToolsMenu, ...
        @FormatMenu, ...
        @AddMenu, ...
        @PatternWizardMenu, ...
        customSchemas{:}, ...
        @HelpMenu};
end

% =========================================================================
% FILE MENU
% =========================================================================
function schema = FileMenu(~)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:FileMenu';
    schema.label        = '&File';
    schema.generateFcn  = @GenerateFileMenu;
end

function schema = GenerateFileMenu(~)
    schema = {@NewModelMenuItem, ...
        @OpenModelMenuItem, ...
        @SaveModelMenuItem, ...
        @SaveModelAsMenuItem, ...
        'separator', ...
        @CloseMenuItem, ...
        @CloseAllChartsMenuItem, ...
        'separator', ...
        @SourceControlMenu, ...
        'separator', ...
        @ChartPropertiesMenuItem, ...
        @MachinePropertiesMenuItem, ...
        'separator', ...
        @ExportToWeb, ...
        @PrintMenuItem, ...
        @PrintDetailsMenuItem, ...
        @PrintCurrentViewMenu, ...
        @PrintSetupMenuItem, ...
        @EnableTiledPrinting ...
        };
    
    customSchemas = cm_get_custom_schemas('Stateflow:FileMenu');
    
    schema = {schema{:}, ...
        'separator', ...
        customSchemas{:}, ...
        'separator', ...
        @ExitMATLABMenuItem};
end

% -------------------------------------------------------------------------
% New Model
% -------------------------------------------------------------------------
function schema = NewModelMenuItem(~)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:NewModelMenuItem';
    schema.label       = '&New Model';
    schema.accelerator = 'N';
    schema.callback    = @callback_fcn;
end

% -------------------------------------------------------------------------
% Open Model
% -------------------------------------------------------------------------
function schema = OpenModelMenuItem(~)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:OpenModelMenuItem';
    schema.label       = '&Open Model...';
    schema.accelerator = 'O';
    schema.callback    = @callback_fcn;
end

% -------------------------------------------------------------------------
% Save Model
% -------------------------------------------------------------------------
function schema = SaveModelMenuItem(~)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:SaveModelMenuItem';
    schema.label       = '&Save Model';
    schema.accelerator = 'S';
    schema.callback    = @callback_fcn;
end

% -------------------------------------------------------------------------
% Save Model As
% -------------------------------------------------------------------------
function schema = SaveModelAsMenuItem(~)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:SaveModelAsMenuItem';
    schema.label    = 'Save Model &As...';
    schema.callback = @callback_fcn;
end

% -------------------------------------------------------------------------
% Close
% -------------------------------------------------------------------------
function schema = CloseMenuItem(~)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:CloseMenuItem';
    schema.label       = '&Close';
    schema.accelerator = 'W';
    schema.callback    = @callback_fcn;
end

% -------------------------------------------------------------------------
% Close All Charts
% -------------------------------------------------------------------------
function schema = CloseAllChartsMenuItem(~)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:CloseAllChartsMenuItem';
    schema.label    = 'C&lose All Charts';
    schema.callback = @callback_fcn;
end

% =========================================================================
% SOURCE CONTROL SUBMENU
% =========================================================================
function schema = SourceControlMenu(cbInfo) 
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:SourceControlMenu';
    schema.label        = 'Source Con&trol';
    
    schema.state = 'Disabled';
    
    try
        if ~strcmpi( cmopts, 'None' )
            schema.state = 'Enabled';
        end
    catch
        % ignore any errors and assume we can't use source control
    end
    
    if(ispc)
        schema.childrenFcns = {@GetLatestVersionMenuItem, ...
            @CheckOutMenuItem, ...
            @CheckInMenuItem, ...
            @UndoCheckOutMenuItem, ...
            'separator', ...
            @AddToSourceControlMenuItem, ...
            @RemoveFromSourceControlMenuItem, ...
            'separator', ...
            @HistoryMenuItem, ...
            @DifferencesMenuItem, ...
            @SCPropertiesMenuItem, ...
            @StartSourceControlSystemMenuItem};
    else
        schema.childrenFcns = {@CheckInMenuItem, ...
            @CheckOutMenuItem, ...
            @UndoCheckOutMenuItem};
    end
    
end

% -------------------------------------------------------------------------
% Get Latest Version
% -------------------------------------------------------------------------
function schema = GetLatestVersionMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:GetLatestVersionMenuItem';
    schema.label    = 'Get Latest Version...';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Check Out
% -------------------------------------------------------------------------
function schema = CheckOutMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:CheckOutMenuItem';
    schema.label    = 'Check Out...';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Check In
% -------------------------------------------------------------------------
function schema = CheckInMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:CheckInMenuItem';
    schema.label    = 'Check In...';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Undo Check-Out
% -------------------------------------------------------------------------
function schema = UndoCheckOutMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:UndoCheckOutMenuItem';
    schema.label    = 'Undo Check-Out...';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Add to Source Control
% -------------------------------------------------------------------------
function schema = AddToSourceControlMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:AddToSourceControlMenuItem';
    schema.label    = 'Add to Source Control...';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Remove from Source Control
% -------------------------------------------------------------------------
function schema = RemoveFromSourceControlMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:RemoveFromSourceControlMenuItem';
    schema.label    = 'Remove from Source Control...';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% History
% -------------------------------------------------------------------------
function schema = HistoryMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:HistoryMenuItem';
    schema.label    = 'History...';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Differences
% -------------------------------------------------------------------------
function schema = DifferencesMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:DifferencesMenuItem';
    schema.label    = 'Differences...';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Properties
% -------------------------------------------------------------------------
function schema = SCPropertiesMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:SCPropertiesMenuItem';
    schema.label    = 'Properties...';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Start Source Control System
% -------------------------------------------------------------------------
function schema = StartSourceControlSystemMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:StartSourceControlSystemMenuItem';
    schema.label    = 'Start Source Control System...';
    schema.callback = @hg_ui_event_fcn;
end
% =========================================================================

% -------------------------------------------------------------------------
% Chart Properties
% -------------------------------------------------------------------------
function schema = ChartPropertiesMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:ChartPropertiesMenuItem';
    schema.label    = 'Chart Properties';
    schema.callback = @callback_fcn;
end

% -------------------------------------------------------------------------
% Machine Properties
% -------------------------------------------------------------------------
function schema = MachinePropertiesMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:MachinePropertiesMenuItem';
    schema.label    = 'Machine Properties';
    schema.callback = @callback_fcn;
end

% -------------------------------------------------------------------------
% Export To Web
% -------------------------------------------------------------------------
function schema = ExportToWeb( callbackInfo )
    schema = sl_action_schema;
    
    schema.label = xlate( 'Export to web...' );
    schema.tag = 'Stateflow:ExportToWeb';
    schema.statusTip = 'Export Stateflow chart to a web document';
    schema.callback = @ExportToWebCallback;
    
    if license( 'test', 'SIMULINK_Report_Gen' )
        schema.state = 'Enabled';
    else
        schema.state = 'Hidden';
    end
end

function ExportToWebCallback( callbackInfo )
    RptgenSL.WebViewExporter.showDialog(callbackInfo.uiObject);
end

% -------------------------------------------------------------------------
% Print
% -------------------------------------------------------------------------
function schema = PrintMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:PrintMenuItem';
    schema.label       = '&Print...';
    schema.accelerator = 'P';
    schema.callback    = @callback_fcn;
end

% -------------------------------------------------------------------------
% Print Details
% -------------------------------------------------------------------------
function schema = PrintDetailsMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:PrintDetailsMenuItem';
    schema.label    = 'Print &Details...';
    schema.callback = @callback_fcn;
end

% =========================================================================
% PRINT CURRENT VIEW SUBMENU
% =========================================================================
function schema = PrintCurrentViewMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:PrintCurrentViewMenu';
    schema.label        = 'P&rint Current View';
    if(ispc)
        schema.childrenFcns = {@ToFileMenu, ...
            @ToClipboardMenu, ...
            @ToFigureMenuItem, ...
            @ToPrinterMenuItem};
    else
        schema.childrenFcns = {@ToFileMenu, ...
            @ToFigureMenuItem, ...
            @ToPrinterMenuItem};
    end
end

% =========================================================================
% TO FILE SUBMENU
% =========================================================================
function schema = ToFileMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:ToFileMenu';
    schema.label        = 'To &File';
    schema.childrenFcns = {@PostScriptMenuItem, ...
        @ColorPostScriptMenuItem, ...
        @EncapsulatedPostScriptMenuItem, ...
        @TiffMenuItem, ...
        @PngMenuItem, ...
        @JpegMenuItem};
end

% -------------------------------------------------------------------------
% PostScript
% -------------------------------------------------------------------------
function schema = PostScriptMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:PostScriptMenuItem';
    schema.label    = 'PostScr&ipt';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Color PostScript
% -------------------------------------------------------------------------
function schema = ColorPostScriptMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:ColorPostScriptMenuItem';
    schema.label    = 'Color Pos&tScript';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Encapsulated PostScript
% -------------------------------------------------------------------------
function schema = EncapsulatedPostScriptMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:EncapsulatedPostScriptMenuItem';
    schema.label    = 'Encaps&ulated PostScript';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Tiff
% -------------------------------------------------------------------------
function schema = TiffMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:TiffMenuItem';
    schema.label    = '&Tiff';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Png
% -------------------------------------------------------------------------
function schema = PngMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:PngMenuItem';
    schema.label    = '&Png';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Jpeg
% -------------------------------------------------------------------------
function schema = JpegMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:JpegMenuItem';
    schema.label    = '&Jpeg';
    schema.callback = @hg_ui_event_fcn;
end
% =========================================================================

% =========================================================================
% TO CLIPBOARD SUBMENU
% =========================================================================
function schema = ToClipboardMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:ToClipboardMenu';
    schema.label        = 'To &Clipboard';
    schema.childrenFcns = {@MetaMenuItem, ...
        @BitMapMenuItem};
end

% -------------------------------------------------------------------------
% Meta
% -------------------------------------------------------------------------
function schema = MetaMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:MetaMenuItem';
    schema.label    = '&Meta';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Bitmap
% -------------------------------------------------------------------------
function schema = BitMapMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:BitMapMenuItem';
    schema.label    = '&Bitmap';
    schema.callback = @hg_ui_event_fcn;
end
% =========================================================================

% -------------------------------------------------------------------------
% To Figure
% -------------------------------------------------------------------------
function schema = ToFigureMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:ToFigureMenuItem';
    schema.label    = 'To Fig&ure';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% To Printer
% -------------------------------------------------------------------------
function schema = ToPrinterMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:ToPrinterMenuItem';
    schema.label    = 'To &Printer';
    schema.callback = @callback_fcn;
end
% =========================================================================

% -------------------------------------------------------------------------
% Print Setup
% -------------------------------------------------------------------------
function schema = PrintSetupMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:PrintSetupMenuItem';
    schema.label    = 'Print Set&up...';
    schema.state    = compute_PrintSetupMenuItem_state;
    schema.callback = @callback_fcn;
end

function state = compute_PrintSetupMenuItem_state(cbInfo)
    if ispc
        state = 'Enabled';
    else
        state = 'Hidden';
    end
end

% -------------------------------------------------------------------------
% Enable Tiled Printing
% -------------------------------------------------------------------------
function schema = EnableTiledPrinting( callbackInfo )
    schema = DAStudio.ToggleSchema;
    schema.tag = 'Stateflow:EnableTiledPrinting';
    schema.label = xlate('&Enable Tiled Printing');
    if strcmp(callbackInfo.uiObject.PaperPositionMode, 'tiled')
        schema.checked = 'Checked';
    else
        schema.checked = 'Unchecked';
    end
    schema.callback = @enableTiledPrintingCallback;
    
end

function enableTiledPrintingCallback( callbackInfo )
    if strcmp(callbackInfo.uiObject.PaperPositionMode, 'tiled')
        callbackInfo.uiObject.PaperPositionMode = 'auto';
    else
        callbackInfo.uiObject.PaperPositionMode = 'tiled';
    end
end

% -------------------------------------------------------------------------
% Exit MATLAB
% -------------------------------------------------------------------------
function schema = ExitMATLABMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:ExitMATLABMenuItem';
    schema.label       = 'E&xit MATLAB';
    schema.accelerator = 'Q';
    schema.callback    = @callback_fcn;
end

%==========================================================================
% EDIT MENU
%==========================================================================
function schema = EditMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:EditMenu';
    schema.label        = '&Edit';
    schema.generateFcn  = @GenerateEditMenu;
end

function schema = GenerateEditMenu(cbInfo)
    schema = {@UndoMenuItem, ...
        @RedoMenuItem, ...
        'separator', ...
        @CutMenuItem, ...
        @CopyMenuItem, ...
        @PasteMenuItem, ...
        'separator', ...
        @SelectAllMenuItem, ...
        'separator', ...
        @StyleMenuItem, ...
        @HighlightingPreferenceMenuItem, ...
        'separator', ...
        @SetFontSizeMenu};
    
    customSchemas = cm_get_custom_schemas('Stateflow:EditMenu');
    
    schema = {schema{:}, ...
        'separator', ...
        customSchemas{:}};
end

% -------------------------------------------------------------------------
% Undo
% -------------------------------------------------------------------------
function schema = UndoMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:UndoMenuItem';
    schema.label       = '&Undo';
    schema.accelerator = 'Z';
    schema.state       = compute_UndoMenuItem_state;
    schema.callback    = @hg_ui_event_fcn;
end

function state = compute_UndoMenuItem_state
    if can_undo
        state = 'Enabled';
    else
        state = 'Disabled';
    end
end

% -------------------------------------------------------------------------
% Redo
% -------------------------------------------------------------------------
function schema = RedoMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:RedoMenuItem';
    schema.label       = '&Redo';
    schema.accelerator = 'Y';
    schema.state       = compute_RedoMenuItem_state;
    schema.callback    = @hg_ui_event_fcn;
end

function state = compute_RedoMenuItem_state
    if can_redo
        state = 'Enabled';
    else
        state = 'Disabled';
    end
end

% -------------------------------------------------------------------------
% Cut
% -------------------------------------------------------------------------
function schema = CutMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:CutMenuItem';
    schema.label       = 'Cu&t';
    schema.accelerator = 'X';
    schema.state       = compute_CtxCutMenuItem_state;
    schema.callback    = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Copy
% -------------------------------------------------------------------------
function schema = CopyMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:CopyMenuItem';
    schema.label       = '&Copy';
    schema.accelerator = 'C';
    schema.state       = compute_CtxCopyMenuItem_state;
    schema.callback    = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Paste
% -------------------------------------------------------------------------
function schema = PasteMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:PasteMenuItem';
    schema.label       = '&Paste';
    schema.accelerator = 'V';
    %schema.state       = compute_CtxPasteMenuItem_state;
    schema.callback    = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Select All
% -------------------------------------------------------------------------
function schema = SelectAllMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:SelectAllMenuItem';
    schema.label       = 'Select &All';
    schema.accelerator = 'A';
    schema.callback    = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Style
% -------------------------------------------------------------------------
function schema = StyleMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:StyleMenuItem';
    schema.label    = 'St&yle...';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Syntax Highlighting preferences...
% -------------------------------------------------------------------------
function schema = HighlightingPreferenceMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:HighlightingPreferenceMenuItem';
    schema.label    = 'Highlighting Preferences...';
    schema.callback = @hg_ui_event_fcn;
end

%==========================================================================
% SET FONT SIZE SUBMENU
%==========================================================================
function schema = SetFontSizeMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:SetFontSizeMenu';
    schema.label        = 'Set &Font Size';
    schema.state        = compute_FontSizeSubmenu_state(cbInfo.uiObject);
    schema.childrenFcns = {{@SetFontSizeMenuItem, '2'}, ...
        {@SetFontSizeMenuItem, '4'}, ...
        {@SetFontSizeMenuItem, '&6'}, ...
        {@SetFontSizeMenuItem, '&8'}, ...
        {@SetFontSizeMenuItem, '&9'}, ...
        {@SetFontSizeMenuItem, '1&0'}, ...
        {@SetFontSizeMenuItem, '1&2'}, ...
        {@SetFontSizeMenuItem, '1&4'}, ...
        {@SetFontSizeMenuItem, '16'}, ...
        {@SetFontSizeMenuItem, '20'}, ...
        {@SetFontSizeMenuItem, '24'}, ...
        {@SetFontSizeMenuItem, '32'}, ...
        {@SetFontSizeMenuItem, '40'}, ...
        {@SetFontSizeMenuItem, '48'}, ...
        {@SetFontSizeMenuItem, '50'}};
end

% -------------------------------------------------------------------------
% 2, 4, 6,8,9,..., 50
% -------------------------------------------------------------------------
function schema = SetFontSizeMenuItem(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:SetFontSizeMenuItem';
    schema.label    = cbInfo.userdata;
    schema.checked  = compute_FontSizeSubmenu_checked(cbInfo);
    schema.callback = @hg_ui_event_fcn;
end

% Don't show the font size menu if nothing is selected
function state = compute_FontSizeSubmenu_state(chart)
    selectedList = sf('SelectedObjectsIn', chart.id);
    if isempty(selectedList) || ~ctx_editor_is_not_iced
        state = 'Disabled';
    else
        state = 'Enabled';
    end
end

function state = compute_FontSizeSubmenu_checked(cbInfo)
    state = 'Unchecked';
    
    % Extract the integer font size of the menu item
    sizeString = cbInfo.userdata;
    sizeString(sizeString=='&') = [];
    sizeInt = sscanf(sizeString,'%d');
    
    % NOTE: if at least one selected item has the fontSize equal
    % to this particular menu item, then check it!
    chart = cbInfo.uiObject;
    selectedList = sf('SelectedObjectsIn', chart.id);
    if(~isempty(selectedList))
        types  = get_type;
        for obj=selectedList
            t = get_type(obj);
            if(t.type == types.JUNCT)
                continue; % Skip junctions, no fontSize attribute
            end
            if(sizeInt == sf('get', obj, '.fontSize'))
                state = 'Checked';
                break;
            end
        end
    end
end

%==========================================================================
% VIEW MENU
%==========================================================================
function schema = ViewMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:ViewMenu';
    schema.label        = '&View';
    schema.generateFcn  = @GenerateViewMenu;
end

function schema = GenerateViewMenu(cbInfo)
    schema = {@BackMenuItem, ...
        @ForwardMenuItem, ...
        @GoToParentMenuItem, ...
        'separator', ...
        @ShowTransitionExecutionOrderItem, ...
        'separator', ...
        @ShowPageBoundaries, ...
        'separator', ...
        @RemoveHighlightingMenuItem, ...
        'separator', ...
        @ModelExplorerMenuItem, ...
        @Desktop, ...
        'separator', ...
        @ToolBarMenuItem};
    
    customSchemas = cm_get_custom_schemas('Stateflow:ViewMenu');
    
    schema = {schema{:}, ...
        'separator', ...
        customSchemas{:}};
end

function schema = Desktop( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Stateflow:Desktop';
    schema.label = xlate('MATLAB &Desktop');
    
    % on UNIX platforms you can't
    %   bring the commandwindow forward unless
    %   you're using the Desktop.
    if ~ispc && ~usejava('desktop'),
        schema.state = 'disabled';
    end
    schema.callback = @bringDesktopForward;
end

function bringDesktopForward(callback)
    commandwindow;
end

% -------------------------------------------------------------------------
% Back
% -------------------------------------------------------------------------
function schema = BackMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:BackMenuItem';
    schema.label    = '&Back';
    schema.state    = compute_BackMenuItem_state;
    schema.callback = @hg_ui_event_fcn;
end

function state = compute_BackMenuItem_state(cbInfo)
    if sf('CanGoBack')
        state = 'Enabled';
    else
        state = 'Disabled';
    end
end

% -------------------------------------------------------------------------
% Forward
% -------------------------------------------------------------------------
function schema = ForwardMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:ForwardMenuItem';
    schema.label    = '&Forward';
    schema.state    = compute_ForwardMenuItem_state;
    schema.callback = @hg_ui_event_fcn;
end

function state = compute_ForwardMenuItem_state(cbInfo)
    if sf('CanGoForward')
        state = 'Enabled';
    else
        state = 'Disabled';
    end
end

% -------------------------------------------------------------------------
% Go To Parent
% -------------------------------------------------------------------------
function schema = GoToParentMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:GoToParentMenuItem';
    schema.label    = 'Go To &Parent';
    schema.callback = @hg_ui_event_fcn;
end


function schema = ShowTransitionExecutionOrderItem(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:ShowTransitionExecutionOrderItem';
    schema.label    = 'Show Transition Execution Order';
    schema.checked  = compute_ShowTransitionExecutionOrderItem_checked;
    schema.callback = @hg_ui_event_fcn;
end


function schema = ShowPageBoundaries(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:ShowPageBoundaries';
    schema.label    = xlate('Show Page Boundaries');
    schema.checked  = are_page_boundaries_visible(cbInfo.uiObject);
    schema.callback = @toggle_page_boundaries_visible;
    schema.state    = are_page_boundaries_enabled(cbInfo.uiObject);
    
end

function en = are_page_boundaries_enabled(chart)
    if (isequal(chart.up.PaperPositionMode, 'tiled'))
        en = 'enabled';
    else
        en = 'disabled';
    end
end

function vis = are_page_boundaries_visible(chart)
    
    if (isequal(chart.ShowPageBoundaries, 'on') && ...
            isequal(chart.up.PaperPositionMode, 'tiled'));
        vis = 'checked';
    else
        vis = 'unchecked';
    end
end

function toggle_page_boundaries_visible(cbInfo)
    chart = cbInfo.uiObject;
    if (isequal(chart.ShowPageBoundaries, 'on'))
        chart.ShowPageBoundaries = 'off';
    else
        chart.ShowPageBoundaries = 'on';
    end
end

function schema = RemoveHighlightingMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:RemoveHighlightingMenuItem';
    schema.label    = xlate('&Remove Highlighting');
    schema.state    = compute_RemoveHighlightingMenuItem_state(cbInfo);
    schema.callback = @remove_highlighting;
end

function state = compute_RemoveHighlightingMenuItem_state(cbInfo)
    % compute state for the menu item
    state = 'Enabled';
end

function remove_highlighting(cbInfo)
    % remove both stateflow and simulink highlighting
    machineId = actual_machine_referred_by(sf('CurrentEditorId'));
    modelName = sf('get', machineId, 'machine.name');
    slprivate('remove_hilite', modelName);
end

% -------------------------------------------------------------------------
% Model Explorer
% -------------------------------------------------------------------------
function schema = ModelExplorerMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:ModelExplorerMenuItem';
    schema.label       = 'Model &Explorer';
    schema.accelerator = 'H';
    schema.callback    = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Toolbar
% -------------------------------------------------------------------------
function schema = ToolBarMenuItem(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:ToolBarMenuItem';
    schema.label    = xlate('Toolbar');
    schema.checked  = compute_ToolBarMenuItem_checked;
    schema.callback = @toggle_toolbar_visible;
end

function checked = compute_ShowTransitionExecutionOrderItem_checked
    chartId = sf('CurrentEditorId');
    if ~sf('get', chartId, '.dontShowTransitionExecutionOrder')
        checked = 'Checked';
    else
        checked = 'Unchecked';
    end
end

function checked = compute_ToolBarMenuItem_checked
    chartId = sf('CurrentEditorId');
    if sf('get', chartId, '.toolbarVis')
        checked = 'Checked';
    else
        checked = 'Unchecked';
    end
end

function toggle_toolbar_visible(cbInfo)
    chartId = sf('CurrentEditorId');
    checked = sf('get', chartId, '.toolbarVis');
    sf('set', chartId, '.toolbarVis', ~checked);
end


% =========================================================================
% SIMULATION MENU
% =========================================================================
function schema = SimulationMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:SimulationMenu';
    schema.label        = '&Simulation';
    schema.generateFcn  = @GenerateSimulationMenu;
end

function schema = GenerateSimulationMenu(cbInfo)
    schema = {@StartMenuItem, ...
        @PauseMenuItem, ...
        @StopMenuItem, ...
        @TargetConnectionMenuItem, ...
        @ConfigurationParametersMenuItem};
    
    customSchemas = cm_get_custom_schemas('Stateflow:SimulationMenu');
    
    schema = {schema{:}, ...
        'separator', ...
        customSchemas{:}};
end


% -------------------------------------------------------------------------
% Start
% -------------------------------------------------------------------------
function schema = StartMenuItem(cbInfo)
    
    chartId   = sf('CurrentEditorId');
    isExtMode = sim_mode_is_external(chartId);
    
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:StartMenuItem';
    schema.state       = compute_StartMenuItem_state(isExtMode);
    schema.callback    = @hg_ui_event_fcn;
    
    if sf('get',chartId,'chart.simulationMode') == 3 % PAUSED
        schema.label = '&Continue';
    elseif isExtMode
        schema.label   = '&Start Real-Time Code';
        if strcmp(schema.state, 'Disabled')
            schema.accelerator = 'T';
        end
    else
        schema.label   = '&Start';
        if strcmp(schema.state, 'Enabled');
            schema.accelerator = 'T';
        end
    end
end

function state = compute_StartMenuItem_state(isExtMode)
    chartId   = sf('CurrentEditorId');
    
    % simulationMode enum:
    % 0 = STOPPED = 0,
    % 1 = RUNNING,
    % 2 = RUNNING_FROM_COMMAND_LINE,
    % 3 = PAUSED,
    % 4 = EXTERNAL_CONNECTING,
    % 5 = EXTERNAL_WAITING,
    % 6 = EXTERNAL_RUNNING
    switch(sf('get',chartId,'chart.simulationMode'))
        case 0
            if isExtMode
                state = 'Disabled';
            else
                state = 'Enabled';
            end
        case {3,5}
            state = 'Enabled';
        otherwise
            state = 'Disabled';
    end
end

% -------------------------------------------------------------------------
% Pause
% -------------------------------------------------------------------------
function schema = PauseMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:PauseMenuItem';
    schema.label       = '&Pause';
    schema.state       = compute_PauseMenuItem_state;
    schema.callback    = @hg_ui_event_fcn;
end

function state = compute_PauseMenuItem_state
    chartId   = sf('CurrentEditorId');
    
    % simulationMode enum:
    % 0 = STOPPED = 0,
    % 1 = RUNNING,
    % 2 = RUNNING_FROM_COMMAND_LINE,
    % 3 = PAUSED,
    % 4 = EXTERNAL_CONNECTING,
    % 5 = EXTERNAL_WAITING,
    % 6 = EXTERNAL_RUNNING
    switch(sf('get',chartId,'chart.simulationMode'))
        case 1
            state = 'Enabled';
        otherwise
            state = 'Hidden';
    end
end

% -------------------------------------------------------------------------
% Stop
% -------------------------------------------------------------------------
function schema = StopMenuItem(cbInfo)
    
    isExtMode = sim_mode_is_external(cbInfo.uiObject.Id);
    
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:StopMenuItem';
    schema.state    = compute_StopMenuItem_state(isExtMode);
    schema.callback = @hg_ui_event_fcn;
    
    if isExtMode
        schema.label   = 'S&top Real-Time Code';
    else
        schema.label   = 'S&top';
        if strcmp(schema.state, 'Enabled')
            schema.accelerator = 'T';
        end
    end
end

function state = compute_StopMenuItem_state(isExtMode)
    chartId   = sf('CurrentEditorId');
    
    % simulationMode enum:
    % 0 = STOPPED = 0,
    % 1 = RUNNING,
    % 2 = RUNNING_FROM_COMMAND_LINE,
    % 3 = PAUSED,
    % 4 = EXTERNAL_CONNECTING,
    % 5 = EXTERNAL_WAITING,
    % 6 = EXTERNAL_RUNNING
    switch(sf('get',chartId,'chart.simulationMode'))
        case {1,3,6}
            state = 'Enabled';
        case 0
            if isExtMode
                state = 'Hidden';
            else
                state = 'Disabled';
            end
        otherwise
            state = 'Disabled';
    end
end

% -------------------------------------------------------------------------
% Connect to(Disconnect from) target
% -------------------------------------------------------------------------
function schema = TargetConnectionMenuItem(cbInfo)
    
    isExtMode = sim_mode_is_external(cbInfo.uiObject.Id);
    
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:TargetConnectionMenuItem';
    schema.callback = @hg_ui_event_fcn;
    [schema.label, schema.accelerator] = compute_TargetConnectionMenuItem_label;
    
    if isExtMode
        schema.state = 'Enabled';
    else
        schema.state = 'Hidden';
    end
end

function [label, accel] = compute_TargetConnectionMenuItem_label
    chartId   = sf('CurrentEditorId');
    accel = '';
    label = '';
    
    % simulationMode enum:
    % 0 = STOPPED = 0,
    % 1 = RUNNING,
    % 2 = RUNNING_FROM_COMMAND_LINE,
    % 3 = PAUSED,
    % 4 = EXTERNAL_CONNECTING,
    % 5 = EXTERNAL_WAITING,
    % 6 = EXTERNAL_RUNNING
    switch(sf('get',chartId,'chart.simulationMode'))
        case {0, 4}
            label = 'Connec&t To Target';
        case {5, 6}
            label = 'Disconnec&t From Target';
            accel = 'T';
    end
end

% -------------------------------------------------------------------------
% Configuration Parameters
% -------------------------------------------------------------------------
function schema = ConfigurationParametersMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:ConfigurationParametersMenuItem';
    schema.label       = 'Configuration Para&meters...';
    schema.accelerator = 'E';
    schema.callback    = @hg_ui_event_fcn;
end

% =========================================================================
% TOOLS MENU
% =========================================================================
function schema = ToolsMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:ToolsMenu';
    schema.label        = '&Tools';
    schema.generateFcn  = @GenerateToolsMenu;
end

function schema = GenerateToolsMenu(cbInfo)
    schema = {@ExploreMenuItem, ...
        @DebugMenuItem, ...
        @FindMenuItem, ...
        @SearchAndReplaceMenuItem, ...
        @LogChartSignalsMenuItem, ...
        'separator', ...
        @ParseMenuItem, ...
        @RebuildAllMenuItem, ...
        'separator', ...
        @ParseDiagramMenuItem, ...
        @BuildDiagramMenuItem, ...
        @OpenSimulationTargetMenuItem, ...
        @OpenRTWTargetMenuItem, ...
        @OpenHDLTargetMenuItem, ...
        'separator', ...
        @SyntaxHighlightingMenuItem};
    
    customSchemas = cm_get_custom_schemas('Stateflow:ToolsMenu');
    
    schema = {schema{:}, ...
        'separator', ...
        customSchemas{:}};
end

% -------------------------------------------------------------------------
% Explore
% -------------------------------------------------------------------------
function schema = ExploreMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:ExploreMenuItem';
    schema.label       = '&Explore';
    schema.accelerator = 'R';
    schema.callback    = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Debug
% -------------------------------------------------------------------------
function schema = DebugMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:DebugMenuItem';
    schema.label       = '&Debug...';
    schema.accelerator = 'G';
    schema.callback    = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Find
% -------------------------------------------------------------------------
function schema = FindMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:FindMenuItem';
    schema.label       = '&Find...';
    schema.accelerator = 'F';
    schema.callback    = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Search and Replace
% -------------------------------------------------------------------------
function schema = SearchAndReplaceMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:SearchAndReplaceMenuItem';
    schema.label       = 'Search && Rep&lace...';
    schema.accelerator = 'L';
    schema.callback    = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Log chart signals
% -------------------------------------------------------------------------
function schema = LogChartSignalsMenuItem(cbInfo)
    schema             = DAStudio.ActionSchema;
    schema.tag         = 'Stateflow:LogChartSignalsMenuItem';
    schema.label       = xlate('Log Chart Signals...');
    schema.callback    = @LogChartSignalsCallback;
end

function LogChartSignalsCallback(cbInfo)
    try
        hChartBlk = chart2block(cbInfo.uiObject.Id);
        modelrefsiglog('Create', hChartBlk);
    catch
    end
end

% -------------------------------------------------------------------------
% Parse
% -------------------------------------------------------------------------
function schema = ParseMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:ParseMenuItem';
    schema.label    = '&Parse';
    schema.state    = EnableOnlyWhenSimIsStopped(cbInfo.uiObject.Id);
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Rebuild All
% -------------------------------------------------------------------------
function schema = RebuildAllMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:RebuildAllMenuItem';
    schema.label    = xlate('&Rebuild All');
    schema.state    = EnableOnlyWhenSimIsStopped(cbInfo.uiObject.Id);
    schema.callback = @RebuildAllCallback;
end

function RebuildAllCallback(cbInfo)
    chart = cbInfo.uiObject;
    machine = actual_machine_referred_by(chart.Id);
    
    try
        autobuild_driver('rebuildall',machine,'sfun','yes');
    catch
    end
end

% -------------------------------------------------------------------------
% Parse Diagram
% -------------------------------------------------------------------------
function schema = ParseDiagramMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:ParseDiagramMenuItem';
    schema.label    = 'Parse Di&agram';
    schema.state    = EnableOnlyWhenSimIsStopped(cbInfo.uiObject.Id);
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Build
% -------------------------------------------------------------------------
function schema = BuildDiagramMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:BuildDiagramMenuItem';
    schema.label    = xlate('&Build Diagram');
    schema.state    = EnableOnlyWhenSimIsStopped(cbInfo.uiObject.Id);
    schema.callback = @BuildDiagramCallback;
end

function BuildDiagramCallback(cbInfo)
    chart = cbInfo.uiObject;
    machine = actual_machine_referred_by(chart.Id);
    
    try
        autobuild_driver('build',machine,'sfun','yes');
    catch
    end
end

function state = EnableOnlyWhenSimIsStopped(chart)
    % 0 = STOPPED = 0,
    % 1 = RUNNING,
    % 2 = RUNNING_FROM_COMMAND_LINE,
    % 3 = PAUSED,
    % 4 = EXTERNAL_CONNECTING,
    % 5 = EXTERNAL_WAITING,
    % 6 = EXTERNAL_RUNNING
    switch(sf('get',chart,'chart.simulationMode'))
        case 0
            state = 'Enabled';
        otherwise
            state = 'Disabled';
    end
end

% -------------------------------------------------------------------------
% Open Simulation Target
% -------------------------------------------------------------------------
function schema = OpenSimulationTargetMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:OpenSimulationTargetMenuItem';
    schema.label    = 'Open &Simulation Target';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Open RTW Target
% -------------------------------------------------------------------------
function schema = OpenRTWTargetMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:OpenRTWTargetMenuItem';
    schema.label    = 'Open &RTW Target';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Open HDL Target
% -------------------------------------------------------------------------
function schema = OpenHDLTargetMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:OpenHDLTargetMenuItem';
    schema.label    = 'Open HDL Target';
    schema.callback = @hg_ui_event_fcn;
    
    if ~sf('Feature', 'Developer')
        schema.state = 'Hidden';
    end
end

% -------------------------------------------------------------------------
% Syntax Highlighting
% -------------------------------------------------------------------------
function schema = SyntaxHighlightingMenuItem(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:SyntaxHighlightingMenuItem';
    schema.label    = 'Syntax Coloring';
    schema.checked  = compute_SyntaxHighlightingMenuItem_checked;
    schema.callback = @hg_ui_event_fcn;
end

function checked = compute_SyntaxHighlightingMenuItem_checked
    sh = Stateflow.SyntaxHighlighter;
    if sh.Enabled
        checked = 'Checked';
    else
        checked = 'Unchecked';
    end
end

% =========================================================================
% FORMAT MENU
% =========================================================================
function schema = FormatMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:FormatMenu';
    schema.label        = xlate('For&mat');
    schema.generateFcn  = @GenerateFormatMenu;
end

function schema = GenerateFormatMenu(cbInfo)
    
    schema = {  @AlignItemsMenu, ...
        @DistributeItemsMenu, ...
        @ResizeItemsMenu };
    
    customSchemas = cm_get_custom_schemas('Stateflow:FormatMenu');
    
    schema = [schema, ...
        {'separator'}, ...
        customSchemas];
end

% =========================================================================
% ALIGN SUB MENU
% =========================================================================

function schema = AlignItemsMenu( callbackInfo )
    schema = DAStudio.ContainerSchema;
    schema.tag = 'Stateflow:AlignItems';
    schema.label = xlate('Ali&gn Items');
    schema.generateFcn = @AlignItemsMenuChildren;
    schema.state = EnableAlignmentDistributeItem( callbackInfo, 2 );
end

function schemas = AlignItemsMenuChildren( callbackInfo )
    schemas = { @AlignVTop,...
        @AlignVMid,...
        @AlignVBottom,...
        'separator',...
        @AlignHLeft,...
        @AlignHMid,...
        @AlignHRight };
end

function schema = AlignVTop( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Stateflow:AlignItems:AlignVTop';
    schema.label = xlate('Align &Top Edges');
    schema.callback = @DoAlignSelectedItems;
    schema.userdata = 'top';
end

function schema = AlignVMid( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Stateflow:AlignItems:AlignVMid';
    schema.label = xlate('Align Centers &Horizontally');
    schema.callback = @DoAlignSelectedItems;
    schema.userdata = 'vcenter';
end

function schema = AlignVBottom( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Stateflow:AlignItems:AlignVBottom';
    schema.label = xlate('Align &Bottom Edges');
    schema.callback = @DoAlignSelectedItems;
    schema.userdata = 'bottom';
end

function schema = AlignHLeft( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Stateflow:AlignItems:AlignHLeft';
    schema.label = xlate('Align &Left Edges');
    schema.callback = @DoAlignSelectedItems;
    schema.userdata = 'left';
end

function schema = AlignHMid( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Stateflow:AlignItems:AlignHMid';
    schema.label = xlate('Align Centers &Vertically');
    schema.callback = @DoAlignSelectedItems;
    schema.userdata = 'hcenter';
end

function schema = AlignHRight( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Stateflow:AlignItems:AlignHRight';
    schema.label = xlate('Align &Right Edges');
    schema.callback = @DoAlignSelectedItems;
    schema.userdata = 'right';
end

function DoAlignSelectedItems( callbackInfo )
    editor = callbackInfo.uiObject.editor;
    selection = callbackInfo.getSelection();
    focus = GetSelectionFocus(editor, selection);
    
    if ( focus ~= 0 && length( selection ) > 1 )
        editor.alignItems( callbackInfo.userdata, GetSelectionFocus(editor, selection), selection );
    end
end

function focus = GetSelectionFocus( editor, selection )
    % TBD
    focus = editor.alignmentFocus();
    if ( focus == 0 )
        focus = selection(1);
    end
end

function state = EnableAlignmentDistributeItem( callbackInfo, minSelectedItems )
    editor = callbackInfo.uiObject.editor;
    selection = callbackInfo.getSelection();
    focus = GetSelectionFocus(editor, selection);
    
    if ( (focus ~= 0) & (length(selection) >= minSelectedItems) ) %#ok<AND2>
        state = 'Enabled';
    else
        state = 'Disabled';
    end
end

% =========================================================================
% DISTRIBUTE SUB MENU
% =========================================================================

function schema = DistributeItemsMenu( callbackInfo )
    schema = DAStudio.ContainerSchema;
    schema.tag = 'Stateflow:DistributeItems';
    schema.label = xlate('Dis&tribute Items');
    schema.generateFcn = @DistributeItemsMenuChildren;
    schema.state = EnableAlignmentDistributeItem( callbackInfo, 3 );
end

function schemas = DistributeItemsMenuChildren( callbackInfo )
    schemas = { @DistributeCentersHorizontally,...
        @DistributeCentersVertically,...
        'separator',...
        @DistributeSpaceHorizontally,...
        @DistributeSpaceVertically };
end

function schema = DistributeCentersHorizontally( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Stateflow:DistributeItems:DistributeHCenters';
    schema.label = xlate('Distribute Items &Horizontally');
    schema.callback = @DoDistributeItems;
    schema.userdata = { 'centers' 'horizontal' };
end

function schema = DistributeCentersVertically( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Stateflow:DistributeItems:DistributeVCenters';
    schema.label = xlate('Distribute Items &Vertically');
    schema.callback = @DoDistributeItems;
    schema.userdata = { 'centers' 'vertical' };
end

function schema = DistributeSpaceHorizontally( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Stateflow:DistributeItems:DistributeHGaps';
    schema.label = xlate('Make H&orizontal Gaps Even');
    schema.callback = @DoDistributeItems;
    schema.userdata = { 'spaces' 'horizontal' };
end

function schema = DistributeSpaceVertically( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Stateflow:DistributeItems:DistributeVGaps';
    schema.label = xlate('Make V&ertical Gaps Even');
    schema.callback = @DoDistributeItems;
    schema.userdata = { 'spaces' 'vertical' };
end

function DoDistributeItems( callbackInfo )
    editor = callbackInfo.uiObject.editor;
    selection = callbackInfo.getSelection();
    if ( length( selection ) > 2 )
        editor.distributeItems( callbackInfo.userdata{1}, callbackInfo.userdata{2}, selection );
    end
end

% =========================================================================
% RESIZE SUB MENU
% =========================================================================

function schema = ResizeItemsMenu( callbackInfo )
    schema = DAStudio.ContainerSchema;
    schema.tag = 'Stateflow:ResizeItems';
    schema.label = xlate('Resi&ze Items');
    schema.generateFcn = @ResizeItemsMenuChildren;
    schema.state = EnableAlignmentDistributeItem( callbackInfo, 2 );
end

function schemas = ResizeItemsMenuChildren( callbackInfo )
    schemas = { @MakeSameHeight,...
        @MakeSameWidth,...
        @MakeSameSize };
end

function schema = MakeSameHeight( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Stateflow:ResizeItems:MakeSameHeight';
    schema.label = xlate('Make Items Same &Height');
    schema.callback = @DoCloneItemDimension;
    schema.userdata = 'height';
end

function schema = MakeSameWidth( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Stateflow:ResizeItems:MakeSameWidth';
    schema.label = xlate('Make Items Same &Width');
    schema.callback = @DoCloneItemDimension;
    schema.userdata = 'width';
end

function schema = MakeSameSize( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Stateflow:ResizeItems:MakeSameSize';
    schema.label = xlate('Make Items Same &Size');
    schema.callback = @DoCloneItemDimension;
    schema.userdata = 'both';
end

function DoCloneItemDimension( callbackInfo )
    editor = callbackInfo.uiObject.editor;
    selection = callbackInfo.getSelection();
    focus = GetSelectionFocus(editor,selection);
    
    if ( focus ~= 0 && length( selection ) > 1 )
        if ( strcmp(callbackInfo.userdata, 'both') )
            editor.cloneItemDimensions( focus, selection, 'height', 'width' );
        else
            editor.cloneItemDimensions( focus, selection, callbackInfo.userdata );
        end
    end
end

% =========================================================================
% ADD MENU
% =========================================================================
function schema = AddMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:AddMenu';
    schema.label        = '&Add';
    schema.generateFcn  = @GenerateAddMenu;
end

function schema = GenerateAddMenu(cbInfo)
    schema = {@EventMenu, ...
        @DataMenu, ...
        @TargetMenuItem};
    
    customSchemas = cm_get_custom_schemas('Stateflow:AddMenu');
    
    schema = {schema{:}, ...
        'separator', ...
        customSchemas{:}};
end

% =========================================================================
% EVENT SUB MENU
% =========================================================================
function schema = EventMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:EventMenu';
    schema.label        = '&Event';
    schema.childrenFcns = {@EventLocalMenuItem, ...
        @EventInputFromSimulinkMenuItem, ...
        @EventOutputToSimulinkMenuItem};
end

% note the extra space in 'Local..._' 'Input from Simulink..._' etc
% there is a hack in sfcall whereby the distinction between event
% and data is made by this difference.  i will change this later to
% not rely on it, but since im crunched for time now, ill leave it as-is

% -------------------------------------------------------------------------
% Local
% -------------------------------------------------------------------------
function schema = EventLocalMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:EventLocalMenuItem';
    schema.label    = '&Local... ';
    schema.callback = @callback_fcn;
end

% -------------------------------------------------------------------------
% Input from Simulink
% -------------------------------------------------------------------------
function schema = EventInputFromSimulinkMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:EventInputFromSimulinkMenuItem';
    schema.label    = '&Input from Simulink... ';
    schema.callback = @callback_fcn;
end

% -------------------------------------------------------------------------
% Output to Simulink
% -------------------------------------------------------------------------
function schema = EventOutputToSimulinkMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:EventOutputToSimulinkMenuItem';
    schema.label    = '&Output to Simulink... ';
    schema.callback = @callback_fcn;
end

% =========================================================================
% DATA SUB MENU
% =========================================================================
function schema = DataMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:DataMenu';
    schema.label        = '&Data';
    schema.childrenFcns = {@DataLocalMenuItem, ...
        @DataInputFromSimulinkMenuItem, ...
        @DataOutputToSimulinkMenuItem, ...
        @DataConstantMenuItem, ...
        @DataParameterMenuItem, ...
        @DataStoreMemoryMenuItem};
end

% -------------------------------------------------------------------------
% Local
% -------------------------------------------------------------------------
function schema = DataLocalMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:DataLocalMenuItem';
    schema.label    = '&Local...';
    schema.callback = @callback_fcn;
end

% -------------------------------------------------------------------------
% Input from Simulink
% -------------------------------------------------------------------------
function schema = DataInputFromSimulinkMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:DataInputFromSimulinkMenuItem';
    schema.label    = '&Input from Simulink...';
    schema.callback = @callback_fcn;
end

% -------------------------------------------------------------------------
% Output to Simulink
% -------------------------------------------------------------------------
function schema = DataOutputToSimulinkMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:DataOutputToSimulinkMenuItem';
    schema.label    = '&Output to Simulink...';
    schema.callback = @callback_fcn;
end

% -------------------------------------------------------------------------
% Constant
% -------------------------------------------------------------------------
function schema = DataConstantMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:DataConstantMenuItem';
    schema.label    = '&Constant...';
    schema.callback = @callback_fcn;
end

% -------------------------------------------------------------------------
% Parameter
% -------------------------------------------------------------------------
function schema = DataParameterMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:DataParameterMenuItem';
    schema.label    = '&Parameter...';
    schema.callback = @callback_fcn;
end

% -------------------------------------------------------------------------
% Data Store Memory
% -------------------------------------------------------------------------
function schema = DataStoreMemoryMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:DataStoreMemoryMenuItem';
    schema.label    = '&Data Store Memory...';
    schema.callback = @callback_fcn;
end

% -------------------------------------------------------------------------
% Target
% -------------------------------------------------------------------------
function schema = TargetMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:TargetMenuItem';
    schema.label    = '&Target...';
    schema.callback = @callback_fcn;
end

% =========================================================================
% HELP MENU
% =========================================================================
function schema = HelpMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:HelpMenu';
    schema.label        = '&Help';
    schema.generateFcn  = @GenerateHelpMenu;
end

function schema = GenerateHelpMenu(cbInfo)
    schema = {@StateflowHelpMenuItem, ...
        'separator', ...
        @EditorMenuItem, ...
        @HelpDeskMenuItem, ...
        'separator', ...
        @Terms, ...
        @Patents, ...
        'separator', ...
        @AboutStateflowMenuItem};
    
    customSchemas = cm_get_custom_schemas('Stateflow:HelpMenu');
    
    schema = {schema{:}, ...
        'separator', ...
        customSchemas{:}};
end

% -------------------------------------------------------------------------
% Stateflow Help
% -------------------------------------------------------------------------
function schema = StateflowHelpMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:StateflowHelpMenuItem';
    schema.label    = '&Stateflow Help';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Stateflow Help
% -------------------------------------------------------------------------
function schema = EditorMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:EditorMenuItem';
    schema.label    = 'Editor';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Help Desk
% -------------------------------------------------------------------------
function schema = HelpDeskMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:HelpDeskMenuItem';
    schema.label    = 'Help &Desk';
    schema.callback = @hg_ui_event_fcn;
end

% -------------------------------------------------------------------------
% Terms
% -------------------------------------------------------------------------
function schema = Terms( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Stateflow:Terms';
    schema.label = xlate('Terms of Use...');
    schema.callback = @terms_callback;
end

% -------------------------------------------------------------------------
% Patents
% -------------------------------------------------------------------------
function schema = Patents( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.label = xlate('Patents...');
    schema.tag = 'Stateflow:Patents';
    schema.callback = @patents_callback;
end

function terms_callback( callbackInfo )
    try
        edit ([matlabroot, filesep, 'license.txt']);
    catch
        disp(xlate('Error displaying terms...license file not found.'));
    end
end

function patents_callback( callbackInfo )
    try
        edit ([matlabroot, filesep, 'patents.txt']);
    catch
        disp(xlate('Error displaying patent information...patents file not found.'));
    end
end

% -------------------------------------------------------------------------
% About Stateflow
% -------------------------------------------------------------------------
function schema = AboutStateflowMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:AboutStateflowMenuItem';
    schema.label    = '&About Stateflow';
    schema.callback = @hg_ui_event_fcn;
end

% =========================================================================
% CONTEXT MENU
% =========================================================================
function schemas = ContextMenu
    schemas = {...
        @PatternWizardMenu, ...
        'separator', ...
        @AddNoteMenuItem, ...
        @SmartMenuItem, ...
        'separator', ...
        @CtxCutMenuItem, ...
        @CtxCopyMenuItem, ...
        @CtxPasteMenuItem, ...
        'separator', ...
        @CtxBackMenuItem, ...
        @CtxForwardMenuItem, ...
        @CtxGotoParentMenuItem, ...
        'separator', ...
        @RequirementsMenu, ...
        @ContextSLDVMenu, ...
        'separator', ...
        @RTWMenu, ...
        'separator', ...
        @HDLMenu, ...
        'separator', ...
        @ExecutionOrderMenu, ...
        'separator', ...
        @EditNoteText, ...
        'separator', ...
        @CtxFontSizeMenu, ...
        @CtxJunctionSizeMenu, ...
        @ArrowheadSizeMenu, ...
        @CtxTextFormatMenu, ...
        @CtxTextAlignmentMenu, ...
        @FormatMenu, ...
        'separator', ...
        @DecompositionMenu, ...
        @TypeMenu, ...
        @MakeContentsMenu, ...
        @Stateflow.SLINSF.SubchartMan.linkOptionsMenu, ...
        'separator', ...
        @ViewContents, ...
        'separator', ...
        @FitToViewMenuItem, ...
        @CtxSelectAllMenuItem, ...
        'separator', ...
        @CtxExploreMenu, ...
        @CtxDebugMenuItem, ...
        @CtxFindMenuItem, ...
        @EditLibraryMenuItem, ...
        @SendToWorkspaceMenuItem, ...
        'separator', ...
        @PropertiesMenuItem, ...
        @Stateflow.SLINSF.SubchartMan.editBindingMenu};
end

% -------------------------------------------------------------------------
% Smart
% -------------------------------------------------------------------------
function schema = SmartMenuItem(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:SmartMenuItem';
    schema.label    = xlate('Smart');
    schema.state    = compute_SmartMenuItem_state;
    schema.checked  = compute_SmartMenuItem_checked;
    schema.callback = @toggle_smart;
end

function checked = compute_SmartMenuItem_checked
    if ctx_all_wires_are_smart
        checked = 'Checked';
    else
        checked = 'Unchecked';
    end
end

function state = compute_SmartMenuItem_state
    id     = sf('CtxObject');
    t      = get_type(id);
    types  = get_type;
    type   = t.type;
    switch type
        case types.CHART
            state = 'Hidden';
        case types.OR_STATE
            state = 'Hidden';
        case types.AND_STATE
            state = 'Hidden';
        case types.BOX
            state = 'Hidden';
        case types.TRUTHTABLE
            state = 'Hidden';
        case types.EML
            state = 'Hidden';
        case types.SLFUNCTION
            state = 'Hidden';
        case types.FUNCTION
            state = 'Hidden';
        case types.NOTE
            state = 'Hidden';
        case types.TRANS
            if(sf('get', id, '.type') == 0)
                % type==0 means simple transition
                state = 'Enabled';
            else
                %sub/super transitions don't get smart menu
                state = 'Hidden';
            end
        case types.JUNCT
            state = 'Hidden';
    end
end

function toggle_smart(cbInfo)
    editorId = sf('CtxEditorId');
    selection = sf('Selected', editorId);
    WIRE = sf('get', 'default', 'trans.isa');
    wires = sf('find', selection, '.isa', WIRE);
    
    if isempty(wires), return; end;
    
    sf('CtxPushSmartBitForUndo', editorId);
    
    switch lower(get(gcbo, 'checked')),
        case 'on',
            sf('set', wires, '.drawStyle', 'STATIC');
        case 'off',
            sf('set', wires, '.drawStyle', 'SMART');
    end;
end

%--------------------------------------------------------------------------
% ADD NOTE
%--------------------------------------------------------------------------
function schema = AddNoteMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:AddNoteMenuItem';
    schema.label    = xlate('Add Note');
    schema.state    = compute_AddNoteMenuItem_state;
    schema.callback = @add_note;
end

function state = compute_AddNoteMenuItem_state(cbInfo)
    if ~ctx_editor_is_not_iced
        state = 'Disabled';
        return
    end
    t      = get_type(sf('CtxObject'));
    types  = get_type;
    type   = t.type;
    switch type
        case types.CHART
            state = 'Enabled';
        case types.OR_STATE
            state = 'Enabled';
        case types.AND_STATE
            state = 'Enabled';
        case types.BOX
            state = 'Enabled';
        case types.TRUTHTABLE
            state = 'Enabled';
        case types.EML
            state = 'Enabled';
        case types.SLFUNCTION
            state = 'Enabled';
        case types.FUNCTION
            state = 'Enabled';
        case types.NOTE
            state = 'Enabled';
        case types.TRANS
            state = 'Hidden';
        case types.JUNCT
            state = 'Hidden';
    end
end

function add_note(cbInfo)
    [chartId, figPos] = sf('CtxEditorId');
    noteId = sf( 'new','state' ...
        ,'.position', [figPos, 25, 25] ...
        ,'.chart',chartId ...
        ,'.isNoteBox',1 ...
        ,'.labelString','' ...
        ,'.noteBox.italic',1 ...
        );
    subviewerId = sf('get', chartId, '.viewObj');
    sf('RebuildHierarchy', subviewerId);
    sf('EditLabelOfObject',noteId);
end

% -------------------------------------------------------------------------
% Cut
% -------------------------------------------------------------------------
function schema = CtxCutMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:CutMenuItem';
    schema.label    = xlate('Cut');
    schema.state    = compute_CtxCutMenuItem_state;
    schema.callback = @cut;
end

function state = compute_CtxCutMenuItem_state
    % Require non-empty selection AND non-iced editor
    if(ctx_editor_has_a_selection(true))
        state = 'Enabled';
    else
        state = 'Disabled';
    end
end


function cut(cbInfo)
    sf('CtxCut');
end

%--------------------------------------------------------------------------
% COPY
%--------------------------------------------------------------------------
function schema = CtxCopyMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:CopyMenuItem';
    schema.label    = xlate('Copy');
    schema.state    = compute_CtxCopyMenuItem_state;
    schema.callback = @copy;
end

function state = compute_CtxCopyMenuItem_state
    if ctx_editor_has_a_selection(false)
        state = 'Enabled';
    else
        state = 'Disabled';
    end
end

function copy(cbInfo)
    sf('CtxCopy');
end

% -------------------------------------------------------------------------
% Paste
% -------------------------------------------------------------------------
function schema = CtxPasteMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:PasteMenuItem';
    schema.label    = xlate('Paste');
    schema.state    = compute_CtxPasteMenuItem_state;
    schema.callback = @paste;
end

function state = compute_CtxPasteMenuItem_state
    if clipboard_not_empty
        state = 'Enabled';
    else
        state = 'Disabled';
    end
end

function paste(cbInfo)
    sf('CtxPaste');
end

% -------------------------------------------------------------------------
% Back
% -------------------------------------------------------------------------
function schema = CtxBackMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:CtxBackMenuItem';
    schema.label    = xlate('Back');
    schema.state    = compute_BackMenuItem_state;
    schema.callback = @back;
end

function back(cbInfo)
    sf('CtxBack');
end

%--------------------------------------------------------------------------
% FORWARD
%--------------------------------------------------------------------------
function schema = CtxForwardMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:CtxForwardMenuItem';
    schema.label    = xlate('Forward');
    schema.state    = compute_ForwardMenuItem_state;
    schema.callback = @forward;
end

function forward(cbInfo)
    sf('CtxForward');
end

%--------------------------------------------------------------------------
% GO TO PARENT
%--------------------------------------------------------------------------
function schema = CtxGotoParentMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:CtxGotoParentMenuItem';
    schema.label    = xlate('Go To Parent');
    schema.callback = @goto_parent;
end

function goto_parent(cbInfo)
    sf('CtxUp');
end

% =========================================================================
% REQUIREMENTS SUBMENU
% =========================================================================

function schema = RequirementsMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:RequirementsMenu';
    schema.label        = xlate('Requirements');
    schema.state        = compute_RequirementsMenu_state();
    if strcmp(schema.state, 'Enabled')
        % Since free Read-only RMI is included with Simulink, we
        % need to override the otherwise 'Enabled' state if there is no
        % license and no existing requirements. This avoids showing almost
        % empty child menu and an empty fully disabled Edit/Add dialog.
        if ~license('test','sl_verification_validation') && ...
                ( length(cbInfo.getSelection) ~= 1 || ...
                isempty(rmi.getReqs(cbInfo.getSelection.Id)) )
            schema.state = 'Disabled';
        end
    end
    schema.generateFcn  = @generate_RequirementsMenu;
end

function schema = generate_RequirementsMenu(cbInfo)
    cbInfo.userdata = false;
    selectedIds = selected_state_trans();
    if length(selectedIds) > 1
        cbInfo.userdata = selectedIds;
        schema = rmisl.menus_rmi_vector(cbInfo);
    else
        cbInfo.userdata = false;
        schema = rmisl.menus_rmi_object(cbInfo);
    end
end


function state = compute_RequirementsMenu_state
    if rmi_exists
        t      = get_type(sf('CtxObject'));
        types  = get_type;
        type   = t.type;
        switch type
            case types.CHART
                state = 'Enabled';
            case types.OR_STATE
                state = 'Enabled';
            case types.AND_STATE
                state = 'Enabled';
            case types.BOX
                state = 'Enabled';
            case types.TRUTHTABLE
                state = 'Enabled';
            case types.EML
                state = 'Enabled';
            case types.SLFUNCTION
                state = 'Enabled';
            case types.FUNCTION
                state = 'Enabled';
            case types.NOTE
                state = 'Enabled';
            case types.TRANS
                state = 'Enabled';
            case types.JUNCT
                state = 'Hidden';
        end
    else
        state = 'Hidden';
    end
end


function unimplemented(cbInfo)
    disp('unimplemented');
end


% =========================================================================
% SLDV SUBMENU
% =========================================================================

function schema = ContextSLDVMenu( callbackInfo )
    schema = DAStudio.ContainerSchema;
    schema.tag = 'Simulink:ContextSLDVMenu';
    schema.label = xlate('Desi&gn Verifier');
    if  ~license('test','Simulink_Design_Verifier') || ...
            exist('slavteng', 'file')~=3 || ...
            ~isequal( callbackInfo.model.LibraryType, 'None' )
        schema.state = 'Hidden';
        return;
    else
        try
            isAllowed = sldvprivate('util_menu','sldv_menu_allowed',callbackInfo);
        catch Mex %#ok<NASGU>
            isAllowed = false;
        end
        if isAllowed
            schema.state = 'Enabled';               
        else
            schema.state = 'Hidden'; 
            return;
        end
    end
    % MENU STRUCTURE                                       
    %                                                           
    %    Verifier  =>  Check subsystem compatibility       
    %                  --------------------------
    %                  Generate Tests for Subsystem        
    %                  Prove Properties of Subsystem       
    %                  --------------------------
    %                  Settings ...                        
    %        
    if isa(callbackInfo.getSelection, 'Stateflow.AtomicSubchart')
        schema.childrenFcns = {  @DVcompatibilityAtomicSubchart, ...
             'SEPARATOR', ...
             @DVtestgenSubchart, ...
             @DVproveSubchart, ...
             'SEPARATOR', ...
             @DVsettingsSubchart};        
    else
        schema.childrenFcns = { @DVMakeAtomicSubchart} ;
    end
end

function schema = DVMakeAtomicSubchart(callbackInfo)
    schema = DAStudio.ActionSchema;
    schema.label = xlate('Choose ''Make Contents > Atomic subcharted'' to analyze ...');
    schema.tag = 'Stateflow:DVMakeAtomicSubchart';    
    schema.state = 'Disabled';
end

function schema = DVcompatibilityAtomicSubchart(callbackInfo)
    schema = DAStudio.ActionSchema;
    schema.label = xlate('Check Subchart Compatibility');
    schema.tag = 'Stateflow:DVcompatibilityAtomicSubchart';    
    schema.callback = @DVcompatibilityAtomicSubchart_callback;         
end

function schema = DVtestgenSubchart(callbackInfo)
    schema = DAStudio.ActionSchema;
    schema.label = xlate('Generate Tests for Subchart');
    schema.tag = 'Stateflow:DVtestgenSubchart';    
    schema.callback = @DVtestgenSubchart_callback;    
end

function schema = DVproveSubchart(callbackInfo)
    schema = DAStudio.ActionSchema;
    schema.label = xlate('Prove Properties of Subchart');
    schema.tag = 'Stateflow:DVproveSubchart';    
    schema.callback = @DVproveSubchart_callback;    
end

function schema = DVsettingsSubchart(callbackInfo)
    schema = DAStudio.ActionSchema;
    schema.label = xlate('Options ...');
    schema.tag = 'Stateflow:DVsettingsSubchart';    
    schema.callback = @DVsettingsSubchart_callback;    
end

function DVcompatibilityAtomicSubchart_callback(callbackInfo)
    subsystemH = DVgetStateflowSSHandle(callbackInfo);
    sldvprivate('util_menu_callback','sf_atomicsubchart_compat',subsystemH);
end

function DVtestgenSubchart_callback(callbackInfo)
    subsystemH = DVgetStateflowSSHandle(callbackInfo);
    sldvprivate('util_menu_callback','sf_atomicsubchart_testgen',subsystemH);
end

function DVproveSubchart_callback(callbackInfo)
    subsystemH = DVgetStateflowSSHandle(callbackInfo);
    sldvprivate('util_menu_callback','sf_atomicsubchart_prove',subsystemH);
end

function DVsettingsSubchart_callback(callbackInfo)
    subsystemH = DVgetStateflowSSHandle(callbackInfo);
    sldvprivate('util_menu_callback','sf_atomicsubchart_options',subsystemH);
end

function subsystemH = DVgetStateflowSSHandle(callbackInfo)
    % XXX: This will not work with nested linked atomic subcharts.
    subsystemH = sf('get', callbackInfo.getSelection.Id, '.simulink.blockHandle');    
end


% =========================================================================
% RTW SUBMENU
% =========================================================================
function schema = RTWMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:RTWMenu';
    schema.label        = 'Real-Time Workshop';
    schema.state        = compute_RTWMenu_state;
    schema.generateFcn  = @generate_RTWMenu;
end

function schema = generate_RTWMenu(cbInfo)
    
    rt = sfroot;
    objectId = sf('CtxObject');
    objectHandle = rt.idToHandle(objectId);
    objectSSId = [];
    if ~isempty(objectHandle)
        objectSSId = handleTossId(objectHandle);
    end
    objectType = [];
    schema{1} = {@HighlightRTWCodeMenuItem, {objectSSId, objectType}};
    
end

function state = compute_RTWMenu_state
    
    objectId = sf('CtxObject');
    showIt = traceabilityManager('showRTWMenu', objectId);
    
    if showIt
        
        t = get_type(objectId);
        types = get_type;
        type = t.type;
        
        state = 'Enabled';
        switch type
            case types.CHART
                state = 'Hidden';
            case types.OR_STATE
                state = 'Enabled';
            case types.AND_STATE
                state = 'Enabled';
            case types.BOX
                state = 'Hidden';
            case types.TRUTHTABLE
                state = 'Enabled';
            case types.EML
                state = 'Enabled';
            case types.SLFUNCTION
                state = 'Enabled';
            case types.FUNCTION
                state = 'Enabled';
            case types.NOTE
                state = 'Hidden';
            case types.TRANS
                state = 'Enabled';
            case types.JUNCT
                state = 'Enabled';
        end
        
    else
        state = 'Hidden';
    end
end

function schema = HighlightRTWCodeMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:HighlightCodeMenuItem';
    schema.label    = xlate('Navigate to Code...');
    schema.state = compute_HighlightRTWCodeMenuItemState;
    schema.callback = @rtw_highlight_code;
    schema.userdata = cbInfo.userdata{1};
end

function rtw_highlight_code(cbInfo)
    
    % this should be done by rtwtrace
    chartId = sf('CurrentEditorId');
    objectId = sf('CtxObject');
    sf('Highlight', chartId, objectId);
    
    traceabilityManager('rtwTraceObject', cbInfo.userdata);
end

function state = compute_HighlightRTWCodeMenuItemState
    
    objectId = sf('CtxObject');
    showIt = traceabilityManager('rtwHighlightCodeMenuItemEnabled', objectId);
    
    if showIt && ~is_multi_select
        state = 'Enabled';
    else
        state = 'Disabled';
    end
    
end

% =========================================================================
% HDL SUBMENU
% =========================================================================
function schema = HDLMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:HDLMenu';
    schema.label        = 'HDL Coder';
    schema.state        = compute_HDLMenu_state;
    schema.generateFcn  = @generate_HDLMenu;
end

function schema = generate_HDLMenu(cbInfo)
    
    rt = sfroot;
    objectId = sf('CtxObject');
    objectHandle = rt.idToHandle(objectId);
    objectSSId = [];
    if ~isempty(objectHandle)
        objectSSId = handleTossId(objectHandle);
    end
    objectType = [];
    schema{1} = {@HighlightHDLCodeMenuItem, {objectSSId, objectType}};
    
end

function state = compute_HDLMenu_state
    
    objectId = sf('CtxObject');
    showIt = traceabilityManager('showHDLMenu', objectId);
    
    if showIt
        
        t = get_type(objectId);
        types = get_type;
        type = t.type;
        
        state = 'Enabled';
        switch type
            case types.CHART
                state = 'Hidden';
            case types.OR_STATE
                state = 'Enabled';
            case types.AND_STATE
                state = 'Enabled';
            case types.BOX
                state = 'Hidden';
            case types.TRUTHTABLE
                state = 'Enabled';
            case types.EML
                state = 'Enabled';
            case types.FUNCTION
                state = 'Enabled';
            case types.NOTE
                state = 'Hidden';
            case types.TRANS
                state = 'Enabled';
            case types.JUNCT
                state = 'Enabled';
        end
        
    else
        state = 'Hidden';
    end
end

function schema = HighlightHDLCodeMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:HighlightCodeMenuItem';
    schema.label    = xlate('Navigate to Code...');
    schema.state = compute_HighlightHDLCodeMenuItemState;
    schema.callback = @hdl_highlight_code;
    schema.userdata = cbInfo.userdata{1};
end

function hdl_highlight_code(cbInfo)
    
    % this should be done by rtwtrace
    chartId = sf('CurrentEditorId');
    objectId = sf('CtxObject');
    sf('Highlight', chartId, objectId);
    
    traceabilityManager('hdlTraceObject', cbInfo.userdata);
end

function state = compute_HighlightHDLCodeMenuItemState
    
    objectId = sf('CtxObject');
    showIt = traceabilityManager('hdlHighlightCodeMenuItemEnabled', objectId);
    
    if showIt && ~is_multi_select
        state = 'Enabled';
    else
        state = 'Disabled';
    end
    
end

% =========================================================================
% EXECUTION ORDER SUBMENU
% =========================================================================
function schema = ExecutionOrderMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:ExecutionOrderMenu';
    schema.label        = xlate('Execution Order');
    schema.state        = compute_ExecutionOrderMenu_state;
    schema.generateFcn  = @GenerateExecutionOrderMenu;
end

function state = compute_ExecutionOrderMenu_state
    t      = get_type(sf('CtxObject'));
    types  = get_type;
    type   = t.type;
    switch type
        case types.CHART
            chartId = sf('CurrentEditorId');
            ctxObj  = sf('CtxObject');
            if sf('get', chartId, 'chart.userSpecifiedStateTransitionExecutionOrder') || length(sf('SemanticSiblingsOf',ctxObj)) < 1
                state = 'Disabled';
            else
                state = 'Enabled';
            end
        case types.OR_STATE
            state = 'Disabled';
        case types.AND_STATE
            state = 'Enabled';
        case types.BOX
            ctxObj = sf('CtxObject');
            if any( sf('SemanticSiblingsOf',ctxObj) == ctxObj )
                state = 'Enabled';
            else
                state = 'Disabled';
            end
        case types.TRUTHTABLE
            state = 'Disabled';
        case types.EML
            state = 'Disabled';
        case types.SLFUNCTION
            state = 'Disabled';
        case types.FUNCTION
            state = 'Disabled';
        case types.NOTE
            state = 'Disabled';
        case types.TRANS
            state = 'Enabled';
        case types.JUNCT
            state = 'Disabled';
    end
end

function schema = GenerateExecutionOrderMenu(cbInfo)
    chartId = sf('CurrentEditorId');
    if sf('get', chartId, 'chart.userSpecifiedStateTransitionExecutionOrder')
        ctxObj      = sf('CtxObject');
        siblingList = sf('SemanticSiblingsOf',ctxObj);
        schema      = {};
        for i=1:length(siblingList)
            schema{i} = { @ExecutionOrderMenuItem, {i, siblingList} };
        end
    else
        schema = {@EnableUserSpecifiedExecutionOrderMenuItem};
    end
end

%--------------------------------------------------------------------------
% Enable User Specified Execution Order
%--------------------------------------------------------------------------
function schema = EnableUserSpecifiedExecutionOrderMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:EnableUserSpecifiedExecutionOrderMenuItem';
    schema.label    = xlate('Enable user-specified-execution-order for this chart ...');
    schema.state    = compute_EnableUserSpecifiedExecutionOrderMenuItem_state;
    schema.callback = @enable_user_specified_execution_order;
end

function state = compute_EnableUserSpecifiedExecutionOrderMenuItem_state
    chartId = sf('CurrentEditorId');
    if sf('get', chartId, 'chart.userSpecifiedStateTransitionExecutionOrder')
        state = 'Hidden';
    else
        state = 'Enabled';
    end
end

function enable_user_specified_execution_order(cbInfo)
    sf('Private', 'chartdlg', 'construct', sf('CurrentEditorId'));
end

%--------------------------------------------------------------------------
% Execution Order
%--------------------------------------------------------------------------
function schema = ExecutionOrderMenuItem(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:ExecutionOrderMenuItem';
    schema.label    = num2str(cbInfo.userdata{1});
    schema.checked  = compute_ExecutionOrderMenuItem_checked(cbInfo.userdata);
    schema.callback = @set_execution_order;
    schema.userdata = cbInfo.userdata{1};
    if is_chart_locked()
        schema.state  = 'Disabled';
    else
        schema.state  = 'Enabled';
    end
end


function result = is_chart_locked()
    
    chartId = sf('CtxEditorId');
    activeInstance = sf('get', chartId, '.activeInstance');
    switch activeInstance,
        case 0,
            machineId = sf('get', chartId, '.machine');
            if sf('get', machineId, '.locked')
                result = sf('get', chartId, '.locked');
            else
                result = 0;
            end;
            return;
    end;
    result = 1;
end


function checked = compute_ExecutionOrderMenuItem_checked(vararg)
    i           = vararg{1};
    siblingList = vararg{2};
    ctxObj      = sf('CtxObject');
    
    if sf('get', siblingList(i), '.executionOrder') == sf('get', ctxObj, '.executionOrder' )
        checked = 'Checked';
    else
        checked = 'Unchecked';
    end
end

function set_execution_order(cbInfo)
    order = cbInfo.userdata;
    sf('CtxSetExecOrder', order);
end

%--------------------------------------------------------------------------
% Edit Note Text
%--------------------------------------------------------------------------
function schema = EditNoteText(cbInfo)
    schema              = DAStudio.ActionSchema;
    schema.tag          = 'Stateflow:EditNoteText';
    schema.label        = xlate('Edit note text');
    
    if CallbackObjectIsNote && ctx_editor_is_not_iced
        schema.state = 'Enabled';
    else
        schema.state = 'Hidden';
    end
    
    schema.callback     = 'sf(''EditNoteLabel'');';
end

% =========================================================================
% FONT SIZE
% =========================================================================
function schema = CtxFontSizeMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:CtxFontSizeMenu';
    schema.label        = xlate('Font Size');
    schema.state        = compute_CtxFontSizeMenu_state;
    schema.generateFcn  = @GenerateCtxFontSizeMenu;
end

function schema = GenerateCtxFontSizeMenu(cbInfo)
    schema = {{@CtxFontSizeMenuItem, 2}, ...
        {@CtxFontSizeMenuItem, 4}, ...
        {@CtxFontSizeMenuItem, 6}, ...
        {@CtxFontSizeMenuItem, 8}, ...
        {@CtxFontSizeMenuItem, 9}, ...
        {@CtxFontSizeMenuItem, 10}, ...
        {@CtxFontSizeMenuItem, 12}, ...
        {@CtxFontSizeMenuItem, 14}, ...
        {@CtxFontSizeMenuItem, 16}, ...
        {@CtxFontSizeMenuItem, 20}, ...
        {@CtxFontSizeMenuItem, 24}, ...
        {@CtxFontSizeMenuItem, 32}, ...
        {@CtxFontSizeMenuItem, 40}, ...
        {@CtxFontSizeMenuItem, 48}, ...
        {@CtxFontSizeMenuItem, 50}};
end

function state = compute_CtxFontSizeMenu_state(cbInfo)
    if ~ctx_editor_is_not_iced
        state = 'Disabled';
        return
    end
    
    t      = get_type(sf('CtxObject'));
    types  = get_type;
    type   = t.type;
    switch type
        case types.CHART
            state = 'Disabled';
        case types.OR_STATE
            state = 'Enabled';
        case types.AND_STATE
            state = 'Enabled';
        case types.BOX
            state = 'Enabled';
        case types.TRUTHTABLE
            state = 'Enabled';
        case types.EML
            state = 'Enabled';
        case types.SLFUNCTION
            state = 'Enabled';
        case types.FUNCTION
            state = 'Enabled';
        case types.NOTE
            state = 'Enabled';
        case types.TRANS
            state = 'Enabled';
        case types.JUNCT
            state = 'Hidden';
    end
end

% -------------------------------------------------------------------------
% 2 4 6 8 10 12, etc
% -------------------------------------------------------------------------
function schema = CtxFontSizeMenuItem(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:CtxFontSizeMenuItem';
    schema.label    = sf_scalar2str(cbInfo.userdata);
    schema.checked  = compute_CtxFontSizeMenuItem_checked(cbInfo.userdata);
    schema.callback = @font_size;
    schema.userdata = cbInfo.userdata;
end

function state = compute_CtxFontSizeMenuItem_checked(fontSize)
    obj = sf('CtxObject');
    if(fontSize == sf('get', obj, '.fontSize'))
        state = 'Checked';
    else
        state = 'Unchecked';
    end
end

function font_size(cbInfo)
    sf('CtxSetFontSize', cbInfo.userdata);
end

% =========================================================================
% JUNCTION SIZE
% =========================================================================
function schema = CtxJunctionSizeMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:CtxJunctionSizeMenu';
    schema.label        = xlate('Junction Size');
    schema.state        = compute_CtxJunctionSizeMenu_state;
    schema.childrenFcns = {{@CtxJunctionSizeMenuItem, 2}, ...
        {@CtxJunctionSizeMenuItem, 4}, ...
        {@CtxJunctionSizeMenuItem, 6}, ...
        {@CtxJunctionSizeMenuItem, 7}, ...
        {@CtxJunctionSizeMenuItem, 8}, ...
        {@CtxJunctionSizeMenuItem, 9}, ...
        {@CtxJunctionSizeMenuItem, 10}, ...
        {@CtxJunctionSizeMenuItem, 12}, ...
        {@CtxJunctionSizeMenuItem, 14}, ...
        {@CtxJunctionSizeMenuItem, 16}, ...
        {@CtxJunctionSizeMenuItem, 20}, ...
        {@CtxJunctionSizeMenuItem, 24}, ...
        {@CtxJunctionSizeMenuItem, 32}, ...
        {@CtxJunctionSizeMenuItem, 40}, ...
        {@CtxJunctionSizeMenuItem, 48}, ...
        {@CtxJunctionSizeMenuItem, 50}};
end

function state = compute_CtxJunctionSizeMenu_state(cbInfo)
    t      = get_type(sf('CtxObject'));
    types  = get_type;
    type   = t.type;
    switch type
        case types.CHART
            state = 'Hidden';
        case types.OR_STATE
            state = 'Hidden';
        case types.AND_STATE
            state = 'Hidden';
        case types.BOX
            state = 'Hidden';
        case types.TRUTHTABLE
            state = 'Hidden';
        case types.EML
            state = 'Hidden';
        case types.SLFUNCTION
            state = 'Hidden';
        case types.FUNCTION
            state = 'Hidden';
        case types.NOTE
            state = 'Hidden';
        case types.TRANS
            state = 'Hidden';
        case types.JUNCT
            state = 'Enabled';
    end
end

% -------------------------------------------------------------------------
% 2 4 6 8 10 12, etc
% -------------------------------------------------------------------------
function schema = CtxJunctionSizeMenuItem(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:CtxJunctionSizeMenuItem';
    schema.label    = sf_scalar2str(cbInfo.userdata);
    schema.checked  = compute_CtxJunctionSizeMenuItem_checked(cbInfo.userdata);
    schema.callback = @junction_size;
    schema.userdata = cbInfo.userdata;
end

function state = compute_CtxJunctionSizeMenuItem_checked(size)
    obj = sf('CtxObject');
    if(size == sf('get', obj, '.position.radius'))
        state = 'Checked';
    else
        state = 'Unchecked';
    end
end

function junction_size(cbInfo)
    sf('CtxSetJunctionSize', cbInfo.userdata);
end

% =========================================================================
% ARROWHEAD SIZE
% =========================================================================
function schema = ArrowheadSizeMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:ArrowheadSizeMenu';
    schema.label        = xlate('Arrowhead Size');
    schema.state        = compute_ArrowheadSizeMenu_state;
    schema.childrenFcns = {{@ArrowheadSizeMenuItem, 2}, ...
        {@ArrowheadSizeMenuItem, 4}, ...
        {@ArrowheadSizeMenuItem, 6}, ...
        {@ArrowheadSizeMenuItem, 7}, ...
        {@ArrowheadSizeMenuItem, 8}, ...
        {@ArrowheadSizeMenuItem, 9}, ...
        {@ArrowheadSizeMenuItem, 10}, ...
        {@ArrowheadSizeMenuItem, 12}, ...
        {@ArrowheadSizeMenuItem, 14}, ...
        {@ArrowheadSizeMenuItem, 16}, ...
        {@ArrowheadSizeMenuItem, 20}, ...
        {@ArrowheadSizeMenuItem, 24}, ...
        {@ArrowheadSizeMenuItem, 32}, ...
        {@ArrowheadSizeMenuItem, 40}, ...
        {@ArrowheadSizeMenuItem, 48}, ...
        {@ArrowheadSizeMenuItem, 50}};
end

function state = compute_ArrowheadSizeMenu_state(cbInfo)
    t      = get_type(sf('CtxObject'));
    types  = get_type;
    type   = t.type;
    switch type
        case types.CHART
            state = 'Disabled';
        case types.OR_STATE
            state = 'Enabled';
        case types.AND_STATE
            state = 'Enabled';
        case types.BOX
            state = 'Enabled';
        case types.TRUTHTABLE
            state = 'Hidden';
        case types.EML
            state = 'Hidden';
        case types.SLFUNCTION
            state = 'Hidden';
        case types.FUNCTION
            state = 'Hidden';
        case types.NOTE
            state = 'Hidden';
        case types.TRANS
            state = 'Enabled';
        case types.JUNCT
            state = 'Enabled';
    end
end

% -------------------------------------------------------------------------
% 2 4 6 8 10 12, etc
% -------------------------------------------------------------------------
function schema = ArrowheadSizeMenuItem(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:ArrowheadSizeMenuItem';
    schema.label    = sf_scalar2str(cbInfo.userdata);
    schema.checked  = compute_CtxArrowheadSizeMenuItem_checked(cbInfo.userdata);
    schema.callback = @arrowhead_size;
    schema.userdata = cbInfo.userdata;
end

function state = compute_CtxArrowheadSizeMenuItem_checked(size)
    obj = sf('CtxObject');
    if(size == sf('get', obj, '.arrowSize'))
        state = 'Checked';
    else
        state = 'Unchecked';
    end
end

function arrowhead_size(cbInfo)
    sf('CtxSetArrowSize', cbInfo.userdata);
end

% =========================================================================
% TEXT FORMAT SUBMENU
% =========================================================================

function schema = CtxTextFormatMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:CtxTextFormatMenu';
    schema.label        = xlate('Text Format');
    
    if CallbackObjectIsNote && ctx_editor_is_not_iced
        schema.state = 'Enabled';
    else
        schema.state = 'Hidden';
    end
    
    schema.childrenFcns = {@BoldMenuItem, ...
        @ItalicMenuItem, ...
        @InterpretModeMenuItem};
end

function toggle_bold_field(varargin)
    sf('CtxSetTextFormat', 'bold');
end

function schema = BoldMenuItem(cbInfo)
    schema              = DAStudio.ToggleSchema;
    schema.tag          = 'Stateflow:BoldMenuItem';
    schema.label        = xlate('Bold');
    schema.callback     = @toggle_bold_field;
    schema.userdata = cbInfo.userdata;
    
    if ctx_all_notes_bold
        schema.checked = 'Checked';
    else
        schema.checked = 'Unchecked';
    end
end

function toggle_italic_field(varargin)
    sf('CtxSetTextFormat', 'italic');
end

function schema = ItalicMenuItem(cbInfo)
    schema              = DAStudio.ToggleSchema;
    schema.tag          = 'Stateflow:ItalicMenuItem';
    schema.label        = xlate('Italic');
    schema.callback     = @toggle_italic_field;
    
    if ctx_all_notes_italic
        schema.checked = 'Checked';
    else
        schema.checked = 'Unchecked';
    end
end


function toggle_interp_field(varargin)
sf('CtxSetTextFormat', 'tex');
end

function schema = InterpretModeMenuItem(cbInfo)
schema              = DAStudio.ToggleSchema;
schema.tag          = 'Stateflow:InterpretModeMenuItem';
schema.label        = xlate('TeX instructions');
schema.callback     = @toggle_interp_field;

if ctx_all_notes_in_tex
    schema.checked = 'Checked';
else
    schema.checked = 'Unchecked';
end
end

% =========================================================================
% TEXT ALIGNMENT SUBMENU
% =========================================================================

function x = CallbackObjectIsNote
    t      = get_type(sf('CtxObject'));
    types  = get_type;
    
    x = isequal( t.type, types.NOTE );
end

function schema = CtxTextAlignmentMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:CtxTextAlignmentMenu';
    schema.label        = xlate('Text Alignment');
    
    if CallbackObjectIsNote && ctx_editor_is_not_iced
        schema.state = 'Enabled';
    else
        schema.state = 'Hidden';
    end
    
    schema.childrenFcns = {@LeftAlignmentMenuItem, ...
        @CenterAlignmentMenuItem, ...
        @RightAlignmentMenuItem};
end

function set_left_align(varargin)
    sf('CtxSetTextAlignment', 'left');
end

function schema = LeftAlignmentMenuItem(cbInfo)
    schema              = DAStudio.ToggleSchema;
    schema.tag          = 'Stateflow:LeftAlignmentMenuItem';
    schema.label        = xlate('Left');
    schema.callback     = @set_left_align;
    
    if ctx_all_notes_left
        schema.checked = 'Checked';
    else
        schema.checked = 'Unchecked';
    end
end

function set_center_align(varargin)
    sf('CtxSetTextAlignment', 'center');
end

function schema = CenterAlignmentMenuItem(cbInfo)
    schema              = DAStudio.ToggleSchema;
    schema.tag          = 'Stateflow:CenterAlignmentMenuItem';
    schema.label        = xlate('Center');
    schema.callback     = @set_center_align;
    
    if ctx_all_notes_center
        schema.checked = 'Checked';
    else
        schema.checked = 'Unchecked';
    end
end

function set_right_align(varargin)
    sf('CtxSetTextAlignment', 'right');
end

function schema = RightAlignmentMenuItem(cbInfo)
    schema              = DAStudio.ToggleSchema;
    schema.tag          = 'Stateflow:RightAlignmentMenuItem';
    schema.label        = xlate('Right');
    schema.callback     = @set_right_align;
    
    if ctx_all_notes_right
        schema.checked = 'Checked';
    else
        schema.checked = 'Unchecked';
    end
end

% =========================================================================
% DECOMPOSITION SUBMENU
% =========================================================================
function schema = DecompositionMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:DecompositionMenu';
    schema.label        = xlate('Decomposition');
    schema.state        = compute_DecompositionMenu_state(cbInfo);
    schema.childrenFcns = {@ExclusiveMenuItem, ...
        @ParallelMenuItem};
end

function state = compute_DecompositionMenu_state(cbInfo)
    if ~ctx_editor_is_not_iced
        state = 'Disabled';
        return
    end
    if isa(cbInfo.getSelection, 'Stateflow.AtomicSubchart')
        state = 'Disabled';
        return;
    end
    t      = get_type(sf('CtxObject'));
    types  = get_type;
    type   = t.type;
    switch type
        case types.CHART
            state = 'Enabled';
        case types.OR_STATE
            state = 'Enabled';
        case types.AND_STATE
            state = 'Enabled';
        case types.BOX
            state = 'Hidden';
        case types.TRUTHTABLE
            state = 'Hidden';
        case types.EML
            state = 'Hidden';
        case types.FUNCTION
            state = 'Hidden';
        case types.SLFUNCTION
            state = 'Hidden';
        case types.NOTE
            state = 'Hidden';
        case types.TRANS
            state = 'Hidden';
        case types.JUNCT
            state = 'Hidden';
    end
end

function schema = ExclusiveMenuItem(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:ExclusiveMenuItem';
    schema.label    = xlate('Exclusive (OR)');
    schema.checked  = compute_ExclusiveMenuItem_checked;
    schema.callback = @exclusive;
end

function exclusive(cbInfo)
    t      = get_type(sf('CtxObject'));
    types  = get_type;
    type   = t.type;
    switch type
        case types.CHART
            sf('CtxAndChartDecomp');
        case { types.OR_STATE types.AND_STATE }
            sf('CtxAndDecomp');
        case types.BOX
        case types.TRUTHTABLE
        case types.EML
        case types.SLFUNCTION
        case types.FUNCTION
        case types.NOTE
        case types.TRANS
        case types.JUNCT
    end
end

function checked = compute_ExclusiveMenuItem_checked
    obj = sf('CtxObject');
    if(sf('get', obj, '.decomposition'))
        checked = 'Unchecked';
    else
        checked = 'Checked';
    end
end

function schema = ParallelMenuItem(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:ParallelMenuItem';
    schema.label    = xlate('Parallel (AND)');
    schema.checked  = compute_ParallelMenuItem_checked;
    schema.callback = @parallel;
end

function parallel(cbInfo)
    t      = get_type(sf('CtxObject'));
    types  = get_type;
    type   = t.type;
    switch type
        case types.CHART
            sf('CtxOrChartDecomp');
        case { types.OR_STATE types.AND_STATE }
            sf('CtxOrDecomp');
        case types.BOX
        case types.TRUTHTABLE
        case types.EML
        case types.SLFUNCTION
        case types.FUNCTION
        case types.NOTE
        case types.TRANS
        case types.JUNCT
    end
end

function checked = compute_ParallelMenuItem_checked
    obj = sf('CtxObject');
    if(~sf('get', obj, '.decomposition'))
        checked = 'Unchecked';
    else
        checked = 'Checked';
    end
end


% =========================================================================
% TYPE SUBMENU
% =========================================================================
function schema = TypeMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:TypeMenu';
    schema.label        = xlate('Type');
    schema.state        = compute_CtxTypeMenu_state(cbInfo);
    schema.generateFcn  = @generate_TypeMenu;
end

function schema = generate_TypeMenu(cbInfo)
    t      = get_type(sf('CtxObject'));
    types  = get_type;
    type   = t.type;
    
    if type == types.OR_STATE || type == types.AND_STATE || type == types.BOX
        schema = {@StateMenuItem, @BoxMenuItem};
    else
        schema = {@JunctTypeToHistoryMenuItem, @JunctTypeToConnectiveMenuItem};
    end
end

function state = compute_CtxTypeMenu_state(cbInfo)
    if ~ctx_editor_is_not_iced
        state = 'Disabled';
        return
    end
    if isa(cbInfo.getSelection, 'Stateflow.AtomicSubchart')
        state = 'Disabled';
        return;
    end    
    t      = get_type(sf('CtxObject'));
    types  = get_type;
    type   = t.type;
    switch type
        case types.CHART
            state = 'Hidden';
        case types.OR_STATE
            state = 'Enabled';
        case types.AND_STATE
            state = 'Enabled';
        case types.BOX
            state = 'Enabled';
        case types.TRUTHTABLE
            state = 'Hidden';
        case types.EML
            state = 'Hidden';
        case types.SLFUNCTION
            state = 'Hidden';
        case types.FUNCTION
            state = 'Hidden';
        case types.NOTE
            state = 'Hidden';
        case types.TRANS
            state = 'Hidden';
        case types.JUNCT
            state = 'Enabled';
    end
end

%--------------------------------------------------------------------------
% State
%--------------------------------------------------------------------------
function schema = StateMenuItem(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:StateMenuItem';
    schema.label    = xlate('State');
    schema.checked  = compute_StateMenuItem_checked;
    schema.callback = @set_type_to_state;
end

function set_type_to_state(cbInfo)
    sf('CtxStateType')
end

function checked = compute_StateMenuItem_checked
    t      = get_type(sf('CtxObject'));
    types  = get_type;
    type   = t.type;
    if(type == types.BOX)
        checked = 'Unchecked';
    else
        checked = 'Checked';
    end
end

%--------------------------------------------------------------------------
% Box
%--------------------------------------------------------------------------
function schema = BoxMenuItem(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:BoxMenuItem';
    schema.label    = xlate('Box');
    schema.checked  = compute_BoxMenuItem_checked;
    schema.callback = @set_type_to_group;
end

function set_type_to_group(cbInfo)
    sf('CtxGroupType')
end

function checked = compute_BoxMenuItem_checked
    t      = get_type(sf('CtxObject'));
    types  = get_type;
    type   = t.type;
    if(type ~= types.BOX)
        checked = 'Unchecked';
    else
        checked = 'Checked';
    end
end

%--------------------------------------------------------------------------
% History
%--------------------------------------------------------------------------
function schema = JunctTypeToHistoryMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:JunctTypeToHistoryMenuItem';
    schema.label    = xlate('History');
    schema.callback = @junct_types_to_history;
end

function junct_types_to_history(cbInfo)
    editor = sf('CurrentEditorId');
    objs   = sf('SelectedObjectsIn', editor);
    sf('CtxPushJunctionTypeForUndo', editor);
    sf('set', objs, 'junction.type', 'HISTORY_JUNCTION');
end

%--------------------------------------------------------------------------
% Connective
%--------------------------------------------------------------------------
function schema = JunctTypeToConnectiveMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:JunctTypeToConnectiveMenuItem';
    schema.label    = xlate('Connective');
    schema.callback = @junct_types_to_connective;
end

function junct_types_to_connective(cbInfo)
    editor = sf('CurrentEditorId');
    objs   = sf('SelectedObjectsIn', editor);
    sf('CtxPushJunctionTypeForUndo', editor);
    sf('set', objs, 'junction.type', 'CONNECTIVE_JUNCTION');
end

% =========================================================================
% MAKE CONTENTS SUBMENU
% =========================================================================
function schema = MakeContentsMenu(cbInfo)
    schema              = DAStudio.ContainerSchema;
    schema.tag          = 'Stateflow:MakeContentsMenu';
    schema.label        = xlate('Make Contents');
    schema.state        = compute_MakeContentsMenu_state(cbInfo);
    schema.childrenFcns = {@GroupedMenuItem, ...
        @SubChartedMenuItem, ...
        @Stateflow.SLINSF.SubchartMan.makeContentsSubchartMenu};
end

function state = compute_MakeContentsMenu_state(cbInfo)
    if ~ctx_editor_is_not_iced
        state = 'Disabled';
        return
    end
    t      = get_type(sf('CtxObject'));
    types  = get_type;
    type   = t.type;
    switch type
        case types.CHART
            state = 'Hidden';
        case types.OR_STATE
            state = 'Enabled';
        case types.AND_STATE
            state = 'Enabled';
        case types.BOX
            state = 'Enabled';
        case types.TRUTHTABLE
            state = 'Hidden';
        case types.EML
            state = 'Hidden';
        case types.SLFUNCTION
            state = 'Hidden';
        case types.FUNCTION
            state = 'Enabled';
        case types.NOTE
            state = 'Hidden';
        case types.TRANS
            state = 'Hidden';
        case types.JUNCT
            state = 'Hidden';
    end
end

% -------------------------------------------------------------------------
% Grouped
% -------------------------------------------------------------------------
function schema = GroupedMenuItem(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:GroupedMenuItem';
    schema.label    = xlate('Grouped');
    schema.state    = compute_GroupedMenuItem_state;
    schema.checked  = compute_GroupedMenuItem_checked;
    schema.callback = @toggle_make_contents_grouped;
end

function state = compute_GroupedMenuItem_state
    ctxEditor = sf('CtxEditorId');
    selection = sf('SelectedObjectsIn', ctxEditor);
    subchartsInOutlineMode = sf('find', selection, 'state.superState', 'SUBCHART', 'state.viewMode', 'OUTLINE');
    
    if ~isempty(subchartsInOutlineMode),
        state = 'Disabled';
        return;
    end
    
    states = sf('get', selection, 'state.id');
    
    if ~isempty(states),
        state = 'Enabled';
    else
        state = 'Disabled';
    end
end

function checked = compute_GroupedMenuItem_checked
    ctxEditor = sf('CtxEditorId');
    selection = sf('SelectedObjectsIn', ctxEditor);
    states    = sf('get', selection, 'state.id');
    groupedStates = sf('find', states, 'state.superState', 'GROUPED');
    
    %
    % special case for subviewing subcharts
    %
    if length(states) == 1 && isequal(states, sf('find', states, 'state.superState', 'SUBCHART', 'state.viewMode', 1, 'state.subgrouped', 1)),
        checked = 'Checked';
        return;
    end
    
    if ~isempty(states) && isequal(states(:), groupedStates(:))
        checked = 'Checked';
    else
        checked = 'Unchecked';
    end
end

function toggle_make_contents_grouped(cbInfo)
    obj = sf('CtxObject');
    
    if ~isempty(sf('find', obj, '.superState', 'GROUPED'))
        sf('CtxUnGroup');
    else
        sf('CtxGroup');
    end
end

% -------------------------------------------------------------------------
% Subcharted
% -------------------------------------------------------------------------
function schema = SubChartedMenuItem(cbInfo)
    schema          = DAStudio.ToggleSchema;
    schema.tag      = 'Stateflow:SubChartedMenuItem';
    schema.label    = xlate('Subcharted');
    
    if enable_subchart
        schema.state = 'Enabled';
    else
        schema.state = 'Disabled';
    end
    
    if ctx_all_subcharted
        schema.checked = 'Checked';
    else
        schema.checked = 'Unchecked';
    end
    
    schema.callback = @toggle_make_contents_subcharted;
end

function toggle_make_contents_subcharted(cbInfo)
    if ctx_all_subcharted
        sf('CtxUnSubchart');
    else
        sf('CtxSubchart');
    end
end

% -------------------------------------------------------------------------
% View Contents
% -------------------------------------------------------------------------
function schema = ViewContents(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:ViewContents';
    schema.label    = xlate('View Contents');
    schema.callback = @view_contents;
    
    funcId = sf('CtxObjectId');
    if isempty(sf('find',funcId,'state.type','FUNC_STATE'))
        schema.state = 'Hidden';
    else
        if sf('get',funcId,'state.truthTable.isTruthTable')
            schema.state = 'Enabled';
        else
            schema.state = 'Hidden';
        end
    end
end

function view_contents(cbInfo)
    sf('ViewContent',sf('CtxObjectId'));
end

% -------------------------------------------------------------------------
% Fit to View
% -------------------------------------------------------------------------
function schema = FitToViewMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:FitToViewMenuItem';
    schema.label    = xlate('Fit To View');
    schema.state     = compute_FitToViewMenuItem_state;
    schema.callback = @fit_to_view;
end

function state = compute_FitToViewMenuItem_state(cbInfo)
    t      = get_type(sf('CtxObject'));
    types  = get_type;
    type   = t.type;
    switch type
        case types.CHART
            state = 'Disabled';
        case types.OR_STATE
            state = 'Enabled';
        case types.AND_STATE
            state = 'Enabled';
        case types.BOX
            state = 'Enabled';
        case types.TRUTHTABLE
            state = 'Enabled';
        case types.EML
            state = 'Enabled';
        case types.SLFUNCTION
            state = 'Enabled';
        case types.FUNCTION
            state = 'Enabled';
        case types.NOTE
            state = 'Enabled';
        case types.TRANS
            state = 'Enabled';
        case types.JUNCT
            state = 'Enabled';
    end
end

function fit_to_view(cbInfo)
    sf('CtxFitToView');
end

% -------------------------------------------------------------------------
% Select All
% -------------------------------------------------------------------------
function schema = CtxSelectAllMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:SelectAllMenuItem';
    schema.label    = xlate('Select All');
    schema.callback = @select_all;
    schema.state    = compute_CtxSelectAllMenuItem_state;
end

function state = compute_CtxSelectAllMenuItem_state
    if ctx_editor_is_not_empty
        state = 'Enabled';
    else
        state = 'Disabled';
    end
end

function select_all(cbInfo)
    sf('CtxSelectAll');
end

% -------------------------------------------------------------------------
% Explore
% -------------------------------------------------------------------------
function schema = CtxExploreMenu(cbInfo)
    ctxObj          = sf('CtxObjectId');
    resolvedSymbols =  unique(sf('ResolvedSymbolsIn',ctxObj));
    
    if isempty(resolvedSymbols)
        schema          = DAStudio.ActionSchema;
        schema.callback = @explore;
        schema.userdata = ctxObj;
    else
        schema             = DAStudio.ContainerSchema;
        schema.generateFcn = @generate_CtxExploreMenu;
    end;
    
    schema.tag      = 'Stateflow:CtxExploreMenu';
    schema.label    = xlate('Explore');
end

function schemas = generate_CtxExploreMenu(cbInfo)
    persistent sObjectTypeStrings
    if(isempty(sObjectTypeStrings))
        sObjectTypeStrings{sf('get','default','machine.isa')+1} = 'machine';
        sObjectTypeStrings{sf('get','default','chart.isa')+1} = 'chart';
        sObjectTypeStrings{sf('get','default','state.isa')+1} = 'state';
        sObjectTypeStrings{sf('get','default','data.isa')+1} = 'data';
        sObjectTypeStrings{sf('get','default','event.isa')+1} = 'event';
        sObjectTypeStrings{sf('get','default','transition.isa')+1} = 'transition';
        sObjectTypeStrings{sf('get','default','junction.isa')+1} = 'junction';
        sObjectTypeStrings{sf('get','default','target.isa')+1} = 'target';
    end
    
    ctxObj          = sf('CtxObjectId');
    resolvedSymbols =  unique(sf('ResolvedSymbolsIn',ctxObj));
    
    %
    % The first submenu is always the selected context object, add it first.
    %
    objType = sf('get',ctxObj,'.isa');
    objTypeStr = sObjectTypeStrings{objType+1};
    
    if isequal(objTypeStr, 'state'),
        if ~isempty(sf('find', ctxObj,'state.type','FUNC_STATE'))
            objTypeStr = 'function';
        elseif ~isempty(sf('find', ctxObj,'state.type','GROUP_STATE'))
            objTypeStr = 'box';
        else
            objTypeStr = sObjectTypeStrings{objType+1};
        end;
    end;
    
    label = sprintf('Selected %s', objTypeStr);
    schemas{1} = {@CtxExploreMenuItem, {ctxObj, label}};
    
    %
    % Add all resolved symbols to the submenu schema list
    %
    for i=1:length(resolvedSymbols)
        symbolObj = resolvedSymbols(i);
        [objType,objName] = sf('get', symbolObj,'.isa','.name');
        if(~isempty(sf('find', symbolObj,'state.type','FUNC_STATE')))
            objTypeStr = 'function';
        else
            objTypeStr = sObjectTypeStrings{objType+1};
        end
        label = sprintf('(%s) %s',objTypeStr,objName);
        schemas{i+1} = {@CtxExploreMenuItem, {symbolObj, label}};
    end
end

function schema = CtxExploreMenuItem(cbInfo)
    id    = cbInfo.userdata{1};
    label = cbInfo.userdata{2};
    
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:CtxExploreMenuItem';
    schema.label    = label;
    schema.callback = @explore;
    schema.userdata = id;
end

function explore(cbInfo)
    objectId = cbInfo.userdata;
    if(~isempty(sf('find',objectId,'event.scope','OUTPUT_EVENT')))
        calleeH = outputevent2callee(objectId);
        if(ishandle(calleeH))
            open_system(calleeH);
        end
    elseif(~isempty(sf('find',objectId,'state.type','FUNC_STATE')))
        sf('Open',objectId);
    else
        sf('Explr');
        sf('Explr','VIEW',objectId);
    end
end

% -------------------------------------------------------------------------
% Debug
% -------------------------------------------------------------------------
function schema = CtxDebugMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:CtxDebugMenuItem';
    schema.label    = xlate('Debug...');
    schema.callback = @debug;
end

function debug(cbInfo)
    ctxEditor = sf('CtxEditorId');
    machine = actual_machine_referred_by(ctxEditor);
    sfdebug('gui','init', machine);
end

% -------------------------------------------------------------------------
% Find
% -------------------------------------------------------------------------
function schema = CtxFindMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:CtxFindMenuItem';
    schema.label    = xlate('Find...');
    schema.callback = @findCallback;
end

function findCallback(cbInfo)
    ctxEditor = sf('CtxEditorId');
    sfsrch('create', ctxEditor);
end

% -------------------------------------------------------------------------
% Edit Library
% -------------------------------------------------------------------------
function schema = EditLibraryMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:EditLibraryMenuItem';
    schema.label    = xlate('Edit Library');
    schema.callback = @edit_library;
    schema.state    = compute_EditLibraryMenuItem_state;
end

function edit_library(cbInfo)
    chartId = sf('CtxEditorId');
    machineId = sf('get', chartId, '.machine');
    libraryH = sf('get',machineId, '.simulinkModel');
    
    % Make sure Library is open in this case (g367403)
    if(strcmp(get_param(libraryH, 'Open'), 'off'))
        open_system(libraryH);
        sf('set', chartId, '.visible', true);
        
    end;
    
    set_param(libraryH, 'lock','off');
    sf('set', chartId, '.activeInstance', 0);
end

function state = compute_EditLibraryMenuItem_state(cbInfo)
    if is_chart_locked
        state = 'Enabled';
    else
        state = 'Disabled';
    end
end

% -------------------------------------------------------------------------
% Send to Workspace
% -------------------------------------------------------------------------
function schema = SendToWorkspaceMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:SendToWorkspaceMenuItem';
    schema.label    = xlate('Send to Workspace');
    schema.callback = @send_to_workspace;
end

function send_to_workspace(cbInfo)
    sf('CtxGetHandle');
end

% -------------------------------------------------------------------------
% Properties
% -------------------------------------------------------------------------
function schema = PropertiesMenuItem(cbInfo)
    schema          = DAStudio.ActionSchema;
    schema.tag      = 'Stateflow:PropertiesMenuItem';
    schema.label    = xlate('Properties');
    schema.callback = @properties;
end

function properties(cbInfo)
    sf('CtxProperties');
end





% =========================================================================
% HELPER FUNCTIONS
% =========================================================================

function x = ctx_editor_is_not_empty
    x = 0;
    ctxEditor = sf('CurrentEditorId');
    objs = sf('ObjectsIn', ctxEditor);
    if ~isempty(objs),
        STATE = sf('get', 'default', 'state.isa');
        TRANS = sf('get', 'default', 'trans.isa');
        JUNCT = sf('get', 'default', 'junct.isa');
        
        states = sf('find', objs, '.isa', STATE);
        trans  = sf('find', objs, '.isa', TRANS);
        juncts = sf('find', objs, '.isa', JUNCT);
        
        objs = [states trans juncts];
        
        if ~isempty(objs)
            x = 1;
        end
    end
end


% -------------------------------------------------------------------------
function x = ctx_editor_has_a_selection(requireNotIced)
    x = true;
    
    % Require editor AND not iced editor if requested
    ctxEditor = sf('CurrentEditorId');
    if(ctxEditor == 0 || requireNotIced && sf('IsChartEditorIced',ctxEditor))
        x = false;
        return;
    end
    
    % Require selection minus autocreated objects
    selectionList = sf('Selected', ctxEditor);
    selectionList = sf('find',selectionList,'.autogen.isAutoCreated',0);
    if(isempty(selectionList))
        x = false;
        return;
    end
    
    % Require that the selection not be ONE subchart that is now subviewed
    if(length(selectionList) == 1)
        id = selectionList(1);
        STATE = sf('get', 'default', 'state.isa');
        
        % Selection id is a state
        if(sf('get', id, '.isa') == STATE)
            % Selection id is subchart (superState 2)
            %          AND is subviewed (viewMode 1)
            if(sf('get',id, '.superState') == 2 && sf('get',id, '.viewMode') == 1)
                x = false;
            end
        end
    end
end

% -------------------------------------------------------------------------
function x = clipboard_not_empty(junk)
    x = ~sf('ClipboardIsEmpty') & ctx_editor_is_not_iced;
end

% -------------------------------------------------------------------------
function x = ctx_editor_is_not_iced
    ctxEditor = sf('CurrentEditorId');
    x = 0;  %test case
    
    if ~sf('IsChartEditorIced',ctxEditor)
        x = 1;
    end
end

% -------------------------------------------------------------------------
function x = ctx_all_wires_are_smart
    
    ctxEditor  = sf('CurrentEditorId');
    selection  = sf('SelectedObjectsIn', ctxEditor);
    types      = get_type;
    wires      = sf('find', selection, '.isa', types.isaTRANS);
    smartWires = sf('find', wires, 'trans.drawStyle', 1);
    if ~isempty(smartWires) && isequal(wires(:), smartWires(:)),
        x = true;
    else
        x = false;
    end
end

function x = ctx_all_notes_are( alignment )
    %
    % See if all selected notes are in appropriate alignment mode
    %
    ctxEditor = sf('CtxEditorId');
    selection = sf('SelectedObjectsIn', ctxEditor);
    notes     = sf('find', selection, 'state.isNoteBox', 1);
    texNotes  = sf('find', notes, 'state.noteBox.horzAlignment', alignment);
    if ~isempty(texNotes) && isequal(notes(:), texNotes(:)), x = true; else x = false; end;
    return;
end

function x = ctx_all_notes_bold(junk)
    %
    % See if all selected notes are in LaTex interperter mode
    %
    ctxEditor = sf('CtxEditorId');
    selection = sf('SelectedObjectsIn', ctxEditor);
    notes     = sf('find', selection, 'state.isNoteBox', 1);
    boldNotes  = sf('find', notes, 'state.noteBox.bold', 1);
    if ~isempty(boldNotes) && isequal(notes(:), boldNotes(:)), x = true; else x = false; end;
end

function x = ctx_all_notes_italic(junk)
    %
    % See if all selected notes are in LaTex interperter mode
    %
    ctxEditor = sf('CtxEditorId');
    selection = sf('SelectedObjectsIn', ctxEditor);
    notes     = sf('find', selection, 'state.isNoteBox', 1);
    italicNotes  = sf('find', notes, 'state.noteBox.italic', 1);
    if ~isempty(italicNotes) && isequal(notes(:), italicNotes(:)), x = true; else x = false; end;
end


function x = ctx_all_notes_left(junk)
    x = ctx_all_notes_are('LEFT_NOTE');
end

function x = ctx_all_notes_center(junk)
    x = ctx_all_notes_are('CENTER_NOTE');
end

function x = ctx_all_notes_right(junk)
    x = ctx_all_notes_are('RIGHT_NOTE');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x = ctx_all_notes_in_tex(junk)
    % See if all selected notes are in LaTex interperter mode
    %
    ctxEditor = sf('CtxEditorId');
    selection = sf('SelectedObjectsIn', ctxEditor);
    notes     = sf('find', selection, 'state.isNoteBox', 1);
    texNotes  = sf('find', notes, 'state.noteBox.interp', 'TEX_NOTE');
    if ~isempty(texNotes) && isequal(notes(:), texNotes(:)), x = true; else x = false; end;
end

function x = function_is_truth_table(junk)
    funcId = sf('CtxObjectId');
    if isempty(sf('find',funcId,'state.type','FUNC_STATE'))
        x = 0;
    else
        x = sf('get',funcId,'state.truthTable.isTruthTable');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = function_is_eml(junk)
    funcId = sf('CtxObjectId');
    if isempty(sf('find',funcId,'state.type','FUNC_STATE'))
        x = 0;
    else
        x = sf('get',funcId,'state.eml.isEML');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = function_isnt_ttable_or_eml
    x = ~function_is_truth_table & ~function_is_eml;
end

function x = selection_has_subchart
    ctxEditor = sf('CtxEditorId');
    selection = sf('SelectedObjectsIn', ctxEditor);
    compsInSelection = sf('find', selection, 'state.simulink.isComponent', 1);
    
    x = ~isempty(compsInSelection);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = enable_subchart
    x = ctx_no_subview_subcharts & function_isnt_ttable_or_eml & ~selection_has_subchart;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_no_subview_subcharts(junk)
    %
    % See if there are NO subcharts in subview mode in the selection list
    %
    ctxEditor = sf('CtxEditorId');
    selection = sf('SelectedObjectsIn', ctxEditor);
    subchartsInSubviewMode = sf('find', selection, 'state.superState', 'SUBCHART', 'state.viewMode', 1); % use number to get around core data dictionary bug!!
    
    if isempty(subchartsInSubviewMode) x=true; else x=false; end;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_all_subcharted(junk)
    %
    % See if all selected items are subcharted
    %
    ctxEditor = sf('CtxEditorId');
    selection = sf('SelectedObjectsIn', ctxEditor);
    states    = sf('get', selection, 'state.id');
    subchartStates = sf('find', states, 'state.superState', 'SUBCHART', 'state.simulink.isComponent', 0);
    
    if ~isempty(states) && isequal(states(:), subchartStates(:)), x = true; else x = false; end;
end

% -------------------------------------------------------------------------
function x = is_multi_select
    selectList = sf('SelectedObjectsIn',sf('CurrentEditorId'));
    x = length(selectList)>1;
end

% -------------------------------------------------------------------------
function ids = selected_state_trans
    selectList = sf('SelectedObjectsIn',sf('CurrentEditorId'));
    stateIsa = sf('get','default','state.isa');
    transIsa = sf('get','default','trans.isa');
    ids = [sf('find',selectList,'state.isa',stateIsa) sf('find',selectList,'trans.isa',transIsa)];
end

% -------------------------------------------------------------------------
function x = can_undo
    x = false;
    
    chartId = sf('CurrentEditorId');
    if(chartId == 0)
        return;
    end
    
    stack   = sf('GetUndoStack', chartId);
    if(~isempty(stack))
        x = true;
    else
        x = false;
    end
end

% -------------------------------------------------------------------------
function x = can_redo
    x = false;
    
    chartId = sf('CurrentEditorId');
    if(chartId == 0)
        return;
    end
    
    stack   = sf('GetRedoStack', chartId);
    if(~isempty(stack))
        x = true;
    else
        x = false;
    end
end

% -------------------------------------------------------------------------
function t = get_type(objectId)
    
    persistent types
    if isempty(types)
        n=0;
        n=n+1;     types.CHART = n;
        n=n+1;  types.OR_STATE = n;
        n=n+1; types.AND_STATE = n;
        n=n+1;       types.BOX = n;
        n=n+1;  types.TRUTHTABLE = n;
        n=n+1;       types.EML = n;
        n=n+1; types.SLFUNCTION = n;
        n=n+1;  types.FUNCTION = n;
        n=n+1;      types.NOTE = n;
        n=n+1;     types.TRANS = n;
        n=n+1;     types.JUNCT = n;
        
        types.BLOCK      = [types.OR_STATE : types.NOTE]; %#ok<NBRAK>
        types.STATE      = [types.OR_STATE , types.AND_STATE];
        types.STATE_LIKE = [types.OR_STATE : types.FUNCTION]; %#ok<NBRAK>
        types.ALL        = [1 : n]; %#ok<NBRAK>
        
        types.isaCHART = sf('get', 'default', 'chart.isa');
        types.isaSTATE = sf('get', 'default', 'state.isa');
        types.isaTRANS = sf('get', 'default', 'trans.isa');
        types.isaJUNCT = sf('get', 'default', 'junct.isa');
    end
    
    if nargin==0
        % return all the types
        t = types;
    else
        switch (sf('get',objectId,'.isa'))
            case types.isaCHART
                t.isa = types.isaCHART;
                t.type = types.CHART;
            case types.isaSTATE
                t.isa = types.isaSTATE;
                if (sf('get',objectId,'state.isNoteBox'))
                    t.type = types.NOTE;
                else
                    switch sf('get',objectId,'state.type')
                        case 0, t.type = types.OR_STATE;
                        case 1, t.type = types.AND_STATE;
                        case 2,
                            if (sf('get', objectId, 'state.truthTable.isTruthTable'))
                                t.type = types.TRUTHTABLE;
                            elseif (sf('get', objectId, 'state.eml.isEML'))
                                t.type = types.EML;
                            elseif (sf('get', objectId, 'state.simulink.isSimulink'))
                                t.type = types.SLFUNCTION;
                            else
                                t.type = types.FUNCTION;
                            end
                        case 3, t.type = types.BOX;
                        otherwise
                            error('Stateflow:UnexpectedError','Unknown Stateflow state/block type');
                    end
                end
            case types.isaTRANS
                t.isa = types.isaTRANS;
                t.type = types.TRANS;
            case types.isaJUNCT
                t.isa = types.isaJUNCT;
                t.type = types.JUNCT;
            otherwise
                error('Stateflow:UnexpectedError','Unknown Stateflow object type');
        end
    end
end

%#ok<*INUSD>
