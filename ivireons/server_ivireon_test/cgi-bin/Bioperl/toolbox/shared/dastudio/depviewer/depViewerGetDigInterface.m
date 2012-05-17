function schemas=depViewerGetDigInterface( whichMenu, callbackInfo )

% Copyright 2005-2006 The MathWorks, Inc.

    persistent iconsLoaded;

    if isempty(iconsLoaded)
        iconsLoaded = 1;
        im = DAStudio.IconManager;
        root = [matlabroot '/toolbox/shared/dastudio/resources/'];
        
        im.addFileToIcon( 'DepViewer:Open', [root 'open.png']);
        im.addFileToIcon( 'DepViewer:Save', [root 'save.png']);
        im.addFileToIcon( 'DepViewer:Print', [root 'print.png']);     
    end

    switch( whichMenu )
        case 'ContextMenu'
            schemas = MenuBar( callbackInfo );
        case 'MenuBar'
            schemas = MenuBar( callbackInfo );
        case 'ToolBars'
            schemas = ToolBars( callbackInfo );
    end
end

function [ui, tab] = loc_parseCallbackInfo( callbackInfo )
    ui = 0;
    tab = 0;
    
    if( ~isempty(callbackInfo{1}) )
        uiID       = callbackInfo{1};
        manager    = DepViewer.DepViewerUIManager;
        
        if( ~manager.isWindowManaged( uiID ) )
            return;
        end
        
        ui         = manager.getUI(uiID); 
    end
    
    if( ~isempty(callbackInfo{2}) )   
        tabID      = callbackInfo{2};
        tab        = ui.getTab(tabID);
    end
    
end

% MenuBar
% =========================================================================

function schemas = MenuBar( callbackInfo ) 
    schemas = { @FileMenu, ...
                @ViewMenu, ...
                @HelpMenu, ...
              };
end

% ToolBars
% =========================================================================

function schemas = ToolBars( callbackInfo ) 
    schemas = { @MainToolBar, ...
              };
end

% File Menu
% =========================================================================

function schema = FileMenu( callbackInfo ) 
    schema = sl_container_schema;
    schema.label = DAStudio.message('Simulink:DepViewer:FileMenuLabel');
    schema.tag = 'DepViewer:FileMenu';
    
    schema.generateFcn = @FileMenuChildren;
end

function schemas = FileMenuChildren( callbackInfo ) 
    schemas = { @NewWindow, ...
                @Open, ...
                'separator', ...
                @Save, ...
                @SaveAs, ...
                'separator', ...
                @Print, ...
                'separator', ...
                @CloseAllModels, ...
                @Close, ...
              };
end

% View Menu
% =========================================================================

function schema = ViewMenu( callbackInfo ) 
    schema = sl_container_schema;
    schema.label = DAStudio.message('Simulink:DepViewer:ViewMenuLabel');
    schema.tag = 'DepViewer:ViewMenu';
    
    schema.generateFcn = @ViewMenuChildren;
end

function schemas = ViewMenuChildren( callbackInfo ) 
    schemas = { @Refresh, ...                
                'separator', ...
                @Orientation, ...
                'separator', ... 
                @ZoomIn, ...
                @ZoomOut, ...
                @ZoomFit, ...
                'separator', ... 
                @DependencyType, ...                
                'separator', ...
                @ShowLegend, ...
                'separator', ...
                @ShowLibraries, ...
                @ShowMathWorksDependencies, ...                   
                'separator', ...
                @ShowFullPath, ...
              };
end


function schema = DependencyType( callbackInfo ) 
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);
    if( ~eq(ui,0) && ~eq(tab,0) )
        schema = DAStudio.ContainerSchema;
        schema.label = DAStudio.message('Simulink:DepViewer:DependencyType');
        schema.tag = 'DepViewer:DependencyType';
        schema.childrenFcns = { @FileDependencies, ...
                                @ModelRefDependenciesInstanceView, ...
                              };
    else
        schema = DAStudio.ToggleSchema;
        schema.label = DAStudio.message('Simulink:DepViewer:OrientationLabel');
        schema.tag = 'DepViewer:Orientation';   
        schema.checked = 'Unchecked';        
        schema.state   = 'Disabled';            
    end                        
end

% Help Menu
% =========================================================================

function schema = HelpMenu( callbackInfo ) 
    schema = sl_container_schema;
    schema.label = DAStudio.message('Simulink:DepViewer:HelpMenuLabel');
    schema.tag = 'DepViewer:HelpMenu';
    
    schema.generateFcn = @HelpMenuChildren;
end

function schemas = HelpMenuChildren( callbackInfo ) 
    schemas = { @Help, ...
                @About, ...       
              };
end

% Main ToolBar
% =========================================================================

function schema = MainToolBar( callbackInfo ) 
    schema = sl_container_schema;
    schema.tag = 'DepViewer:MainToolBar';
    schema.label = DAStudio.message('Simulink:DepViewer:MainToolBar');
    
    schema.childrenFcns = { @Open, ...
                            @Save, ...                            
                            'separator', ...
                            @Print, ...
                          };
end

% Items
% =========================================================================
% --- Open ----------------------------------------------------------------
function schema = Open( callbackInfo ) 
    schema = sl_action_schema;
    
    schema.label = DAStudio.message('Simulink:DepViewer:OpenLabel');
    schema.tag = 'DepViewer:Open';
    schema.icon = schema.tag;
    schema.accelerator = 'Ctrl+O';
    schema.callback = @loc_openAction;
end

function loc_openAction( callbackInfo )
    [ui] = loc_parseCallbackInfo(callbackInfo);  
    if( ~eq(ui,0) )
        uiactions = DepViewerUIActions;
        uiactions.open(ui); 
    end
end

% --- New Window ----------------------------------------------------------------
function schema = NewWindow( callbackInfo ) 
    schema = sl_action_schema;
    
    schema.label = DAStudio.message('Simulink:DepViewer:NewWindowLabel');
    schema.tag = 'DepViewer:NewWindow';
    schema.accelerator = 'Ctrl+W';
    schema.callback = @loc_newWindowAction;
end

function loc_newWindowAction( callbackInfo ) 
    uiactions = DepViewerUIActions;
    uiactions.createWindow();   
end

% --- Save ----------------------------------------------------------------
function schema = Save( callbackInfo ) 
    schema = sl_action_schema;
    
    schema.label = DAStudio.message('Simulink:DepViewer:SaveLabel');
    schema.tag = 'DepViewer:Save';
    schema.icon = schema.tag;
    schema.accelerator = 'Ctrl+S';
    schema.callback = @loc_saveAction;
    
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);    
    if( eq(ui,0) || eq(tab,0) )
        schema.state   = 'Disabled'; 
    else
        schema.state   = 'Enabled';
    end     
end

function loc_saveAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);
    if( ~eq(ui,0) && ~eq(tab,0) )
        uiactions = DepViewerUIActions;
        uiactions.save(ui, tab); 
    end
end

% --- SaveAs --------------------------------------------------------------
function schema = SaveAs( callbackInfo ) 
    schema = sl_action_schema;
    
    schema.label = DAStudio.message('Simulink:DepViewer:SaveAsLabel');
    schema.tag = 'DepViewer:SaveAs';
    schema.callback = @loc_saveAsAction;
    
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);    
    if( eq(ui,0) || eq(tab,0) )
        schema.state   = 'Disabled'; 
    else
        schema.state   = 'Enabled';        
    end     
end

function loc_saveAsAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);
    if( ~eq(ui,0) && ~eq(tab,0) )
        uiactions = DepViewerUIActions;
        uiactions.saveAs(ui, tab);
    end         
end

% % --- Page Setup ----------------------------------------------------------
% function schema = PageSetup( callbackInfo ) 
%     schema = sl_action_schema;
%     
%     schema.label = 'Page Setup...';
%     schema.tag = 'DepViewer:PageSetup';
%     schema.callback = 'disp(''Test:PageSetup'')';
% end

% --- Print ---------------------------------------------------------------
function schema = Print( callbackInfo ) 
    schema = sl_action_schema;
    
    schema.label = DAStudio.message('Simulink:DepViewer:PrintLabel');
    schema.tag = 'DepViewer:Print';
    schema.icon = schema.tag;
    schema.accelerator = 'Ctrl+P';
    schema.callback = @loc_printAction;
    
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);    
    if( eq(ui,0) || eq(tab,0) )
        schema.state   = 'Disabled';      
    end     
end

function loc_printAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);
    if( ~eq(ui,0) && ~eq(tab,0) )
        uiactions = DepViewerUIActions;
        uiactions.print(ui, tab);
    end  
end

% --- CloseAllModels ---------------------------------------------------------
function schema = CloseAllModels( callbackInfo ) 
    schema = sl_action_schema;
    
    schema.label = DAStudio.message('Simulink:DepViewer:CloseAllModelsLabel');
    schema.tag = 'DepViewer:CloseAllModels';
    schema.callback = @loc_CloseAllModelsAction;
end

function loc_CloseAllModelsAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);
    if( ~eq(ui,0) && ~eq(tab,0) )
        uiactions = DepViewerUIActions;
        uiactions.closeAll(ui, tab);
    end      
end


% --- Close dependency viewer ---------------------------------------------
function schema = Close( callbackInfo ) 
    schema = sl_action_schema;
    
    schema.label = DAStudio.message('Simulink:DepViewer:CloseLabel');
    schema.tag = 'DepViewer:CloseDepView';
    schema.callback = @loc_closeAction;
end

function loc_closeAction( callbackInfo )
    ui = loc_parseCallbackInfo(callbackInfo);
    if( ~eq(ui,0) )
        uiactions = DepViewerUIActions;
        uiactions.close(ui);
    end      
end

% % --- Select All ----------------------------------------------------------
% function schema = SelectAll( callbackInfo ) 
%     schema = sl_action_schema;
%     
%     schema.label = 'Select All';
%     schema.tag = 'DepViewer:SelectAll';
%     schema.accelerator = 'Ctrl+A';
%     schema.callback = 'disp(''Test:SelectAll'')';
% end


% --- Zoom In ----------------------------------------------------------
function schema = ZoomIn( callbackInfo ) 
    schema = sl_action_schema;
    schema.label = DAStudio.message('Simulink:DepViewer:ZoomInLabel');
    schema.tag = 'DepViewer:ZoomIn';
    %schema.accelerator = 'Space++';
    schema.callback = @loc_zoomInAction;
    
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);    
    if( eq(ui,0) || eq(tab,0) )
        schema.state   = 'Disabled';      
    end     
end
function loc_zoomInAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);
    if( ~eq(ui,0) && ~eq(tab,0) )
        %uiactions = DepViewerUIActions;
        %uiactions.zoomIn(ui, tab);
        tab.zoomIn();
    end      
end

% --- Zoom Out ----------------------------------------------------------
function schema = ZoomOut( callbackInfo ) 
    schema = sl_action_schema;
    schema.label = DAStudio.message('Simulink:DepViewer:ZoomOutLabel');
    schema.tag = 'DepViewer:ZoomOut';
    %schema.accelerator = 'Space+-';
    schema.callback = @loc_zoomOutAction;
    
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);    
    if( eq(ui,0) || eq(tab,0) )
        schema.state   = 'Disabled';      
    end     
end
function loc_zoomOutAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);
    if( ~eq(ui,0) && ~eq(tab,0) )
        %uiactions = DepViewerUIActions;
        %uiactions.zoomOut(ui, tab);
        tab.zoomOut();
    end      
end

% --- Zoom Fit ----------------------------------------------------------
function schema = ZoomFit( callbackInfo ) 
    schema = sl_action_schema;
    schema.label = DAStudio.message('Simulink:DepViewer:ZoomFitLabel');
    schema.tag = 'DepViewer:ZoomFit';
    %schema.accelerator = 'Space';
    schema.callback = @loc_zoomFitAction;
    
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);    
    if( eq(ui,0) || eq(tab,0) )
        schema.state   = 'Disabled';      
    end     
end
function loc_zoomFitAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);
    if( ~eq(tab,0) )
        uiactions = DepViewerUIActions;
        uiactions.zoomFit(tab);
    end      
end

% --- Refresh ----------------------------------------------------------------
function schema = Refresh( callbackInfo ) 
    schema = sl_action_schema;    
    schema.label = DAStudio.message('Simulink:DepViewer:RefreshLabel');
    schema.tag = 'DepViewer:Refresh';
    schema.accelerator = 'F5';
    schema.callback = @loc_refreshAction;

    [ui, tab] = loc_parseCallbackInfo(callbackInfo);    
    if( eq(ui,0) || eq(tab,0) )
        schema.state   = 'Disabled';      
    end    
end

function loc_refreshAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);
    if( ~eq(ui,0) && ~eq(tab,0) )
        uiactions = DepViewerUIActions;
        uiactions.refresh(ui, tab);      
    end
end

% --- Mode of operation Section --------------------------


% --- FileDependencies ---------------------------

function schema = FileDependencies( callbackInfo )
    schema = DAStudio.ToggleSchema;
    schema.label = DAStudio.message('Simulink:DepViewer:FileDependencies');
    schema.tag = 'DepViewer:FileDependencies';
    schema.callback = @loc_fileDependenciesAction ;

    [ui, tab] = loc_parseCallbackInfo(callbackInfo);   
    if( ~eq(ui,0) && ~eq(tab,0) ) 
        uiactions = DepViewerUIActions;
        editorData = uiactions.getEditorData(tab);
        schema.checked = loc_logicalToString(editorData.showFileDependenciesView, 'Checked', 'Unchecked');  
    else
        schema.checked = 'Unchecked';   
        schema.state   = 'Disabled';            
    end
    
    

end

function loc_fileDependenciesAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo); 
    if( ~eq(ui,0) && ~eq(tab,0) ) 
        uiactions = DepViewerUIActions;
        uiactions.selectFileDependencies(ui, tab);
    end
end


% ---  ModelRefDependenciesInstanceView ----------

function schema = ModelRefDependenciesInstanceView( callbackInfo )
    schema = DAStudio.ToggleSchema;
    schema.label = DAStudio.message('Simulink:DepViewer:ReferencedModelInstances');
    schema.tag = 'DepViewer:ModelRefDependenciesInstanceView';
    schema.callback = @loc_modelRefDependenciesInstanceViewAction ;

    [ui, tab] = loc_parseCallbackInfo(callbackInfo);   
    if( ~eq(ui,0) && ~eq(tab,0) ) 
        uiactions = DepViewerUIActions;
        editorData = uiactions.getEditorData(tab);
        schema.checked = loc_logicalToString(editorData.showInstanceView, 'Checked', 'Unchecked'); 
    else
        schema.checked = 'Unchecked';   
        schema.state   = 'Disabled';           
    end

end

function loc_modelRefDependenciesInstanceViewAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo); 
    if( ~eq(ui,0) && ~eq(tab,0) ) 
        uiactions = DepViewerUIActions;
        uiactions.selectModelRefDependenciesInstanceView(ui, tab);
    end
end


% --- End Mode of operation Section --------------------------


% --- Orientation ----------------------------------------------------------------
function schema = Orientation( callbackInfo ) 
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);   
    if( ~eq(ui,0) && ~eq(tab,0) ) 
        schema = DAStudio.ContainerSchema;
        schema.label = DAStudio.message('Simulink:DepViewer:OrientationLabel');
        schema.tag = 'DepViewer:Orientation';
        schema.childrenFcns = { @Vertical, ...
                                @Horizontal}; 
    else
        schema = DAStudio.ToggleSchema;
        schema.label = DAStudio.message('Simulink:DepViewer:OrientationLabel');
        schema.tag = 'DepViewer:Orientation';   
        schema.checked = 'Unchecked';        
        schema.state   = 'Disabled';            
    end    
    
end

function schema = Vertical( callbackInfo )
    schema = DAStudio.ToggleSchema;
    schema.label = DAStudio.message('Simulink:DepViewer:Vertical');
    schema.tag = 'DepViewer:Vertical';
    schema.callback = @loc_verticalAction ;

    [ui, tab] = loc_parseCallbackInfo(callbackInfo);   
    if( ~eq(ui,0) && ~eq(tab,0) ) 
        uiactions = DepViewerUIActions;
        editorData = uiactions.getEditorData(tab);
        schema.checked = loc_logicalToString(editorData.showVertical, 'Checked', 'Unchecked'); 
    else
        schema.checked = 'Unchecked';   
        schema.state   = 'Disabled';            
    end

end

function loc_verticalAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo); 
    if( ~eq(ui,0) && ~eq(tab,0) ) 
        uiactions = DepViewerUIActions;
        uiactions.setVerticalOrientation(ui, tab);
    end
end

function schema = Horizontal( callbackInfo )
    schema = DAStudio.ToggleSchema;
    schema.label = DAStudio.message('Simulink:DepViewer:Horizontal');
    schema.tag = 'DepViewer:Horizontal';
    schema.callback = @loc_horizontalAction ;
    
    [ui, tab] = loc_parseCallbackInfo(callbackInfo); 
    if( ~eq(ui,0) && ~eq(tab,0) ) 
        uiactions = DepViewerUIActions;
        editorData = uiactions.getEditorData(tab);
        schema.checked = loc_logicalToString(editorData.showHorizontal, 'Checked', 'Unchecked');  
    else
        schema.checked = 'Unchecked';   
        schema.state   = 'Disabled';            
    end
    
end

function loc_horizontalAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);
    if( ~eq(ui,0) && ~eq(tab,0) ) 
        uiactions = DepViewerUIActions;
        uiactions.setHorizontalOrientation(ui, tab);       
    end
end

% % --- ExpandAll ---------------------------------------------------------
% function schema = ExpandAll( callbackInfo ) 
%     schema = sl_action_schema;
%     
%     schema.label = 'Expand All';
%     schema.tag = 'DepViewer:ExpandAll';
%     schema.callback = 'disp(''Test:Expand All'')';
% end

% --- ShowMathWorksDependencies -----------------------------------------
function schema = ShowMathWorksDependencies( callbackInfo )
    schema = DAStudio.ToggleSchema;
    
    schema.label = DAStudio.message('Simulink:DepViewer:ShowMathworksDependenciesLabel');
    schema.tag = 'DepViewer:ShowMathWorksDependencies';
    schema.callback = @loc_showMathWorksDependenciesAction;
    
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);
    if( ~eq(ui,0) && ~eq(tab,0) ) 
        uiactions = DepViewerUIActions;
        editorData = uiactions.getEditorData(tab);
        schema.checked = loc_logicalToString(editorData.showMathWorksDependencies, 'Checked', 'Unchecked');          
        schema.state   = loc_logicalToString(editorData.showFileDependenciesView, 'Enabled', 'Disabled'); 
    else
        schema.checked = 'Unchecked';   
        schema.state   = 'Disabled';            
    end
end

function loc_showMathWorksDependenciesAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);
    if( ~eq(ui,0) && ~eq(tab,0) ) 
        uiactions = DepViewerUIActions;
        uiactions.showMathWorksDependencies(ui, tab);
    else
        schema.checked = 'Unchecked';   
        schema.state   = 'Disabled';            
    end
end

% --- ShowLibraries ------------------------------------------------------
function schema = ShowLibraries( callbackInfo )
    schema = DAStudio.ToggleSchema;
    
    schema.label = DAStudio.message('Simulink:DepViewer:ShowLibrariesLabel');
    schema.tag = 'DepViewer:ShowLibraries';
    schema.callback = @loc_showLibrariesAction ;
    
    [ui, tab] = loc_parseCallbackInfo(callbackInfo); 
    if( ~eq(ui,0) && ~eq(tab,0) ) 
        uiactions = DepViewerUIActions;
        editorData = uiactions.getEditorData(tab);
        schema.checked = loc_logicalToString(editorData.showLibraries, 'Checked', 'Unchecked'); 
        schema.state   = loc_logicalToString(editorData.showFileDependenciesView, 'Enabled', 'Disabled'); 
    else
        schema.checked = 'Unchecked';   
        schema.state   = 'Disabled';            
    end
    
end

function loc_showLibrariesAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo); 
    if( ~eq(ui,0) && ~eq(tab,0) )
        uiactions = DepViewerUIActions;
        uiactions.showLibraries(ui, tab);
    end
end

% --- ShowLegend --------------------------------------------------------
function schema = ShowLegend( callbackInfo )
    schema = DAStudio.ToggleSchema;
    
    schema.label = DAStudio.message('Simulink:DepViewer:ShowLegendLabel');
    schema.tag = 'DepViewer:ShowLegend';
    schema.callback = @loc_showLegendAction;    
    [ui, tab] = loc_parseCallbackInfo(callbackInfo); 
    if( ~eq(ui,0) && ~eq(tab,0) ) 
        uiactions = DepViewerUIActions;
        editorData = uiactions.getEditorData(tab);
        schema.checked = loc_logicalToString(editorData.showLegend, 'Checked', 'Unchecked');   
    else
        schema.checked = 'Unchecked';   
        schema.state   = 'Disabled';            
    end    
end

function loc_showLegendAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);
    if( ~eq(ui,0) && ~eq(tab,0) )
        uiactions = DepViewerUIActions;
        uiactions.showLegend(ui , tab);
    end
end

% --- ShowFullPath --------------------------------------------------------
function schema = ShowFullPath( callbackInfo )
    schema = DAStudio.ToggleSchema;
    
    schema.label = DAStudio.message('Simulink:DepViewer:ShowFullPathLabel');
    schema.tag = 'DepViewer:ShowFullPath';
    schema.callback = @loc_showFullPathAction;
    
    %show full path needs to be disabled when instance view is disabled
    [ui, tab] = loc_parseCallbackInfo(callbackInfo); 
    if( ~eq(ui,0) && ~eq(tab,0) ) 
        uiactions = DepViewerUIActions;
        editorData = uiactions.getEditorData(tab);
        schema.checked = loc_logicalToString(editorData.showFullPath, 'Checked', 'Unchecked');   
        schema.state   = loc_logicalToString(editorData.showInstanceView, 'Enabled', 'Disabled'); 
    else
        schema.checked = 'Unchecked';   
        schema.state   = 'Disabled';         
    end   
end

function loc_showFullPathAction( callbackInfo )
    [ui, tab] = loc_parseCallbackInfo(callbackInfo);  
    if( ~eq(ui,0) && ~eq(tab,0) )
        uiactions = DepViewerUIActions;
        uiactions.showFullPath(ui, tab);
    end
end

% --- Help -------------------------------------------------------------
function schema = Help( callbackInfo ) 
    schema = sl_action_schema;
    
    schema.label = DAStudio.message('Simulink:DepViewer:HelpLabel');
    schema.tag = 'DepViewer:Help';
    schema.callback = @loc_helpAction;
end

function loc_helpAction( callbackInfo )
    [ui] = loc_parseCallbackInfo(callbackInfo); 
    if( ~eq(ui,0) )
        uiactions = DepViewerUIActions;
        uiactions.help(ui);
    end
end

% --- About -------------------------------------------------------------
function schema = About( callbackInfo ) 
    schema = sl_action_schema;
    
    schema.label = DAStudio.message('Simulink:DepViewer:AboutLabel');
    schema.tag = 'DepViewer:About';
    schema.callback = @loc_aboutAction;
end

function loc_aboutAction( callbackInfo )
    [ui] = loc_parseCallbackInfo(callbackInfo); 
    if( ~eq(ui,0) )
        uiactions = DepViewerUIActions;
        uiactions.about(ui);
    end
end

% Utility functions
function enumStr = loc_logicalToString( logicalValue, trueValue, falseValue )
    enumStr = falseValue;
    if ( logicalValue )
        enumStr = trueValue;
    end
end
