function cancelled=findDependenciesAndUpdateEditor(query, uiID, tabID)

% Copyright 2006 The MathWorks, Inc.
   cancelled  = false;
   manager    = DepViewer.DepViewerUIManager;
   ui         = manager.getUI( uiID );
   tab        = ui.getTab( tabID );
   
   editor      = tab.getEditor();
   editorData  = editor.getEditorData();
   app         = tab.getApp();
   appModel    = app.getModel();
   model       = DepViewer.Model; 
   
   %adding the legend
   loc_addLegend(editorData, model, query);
   
   try
       query = load_system(query);
   catch
       msgbox(['Could not load ', query], 'Error finding dependencies', 'error');
       return;
   end % try/catch
      
   if(editorData.showFileDependenciesView)
       assert(~editorData.showInstanceView);

       if(editorData.showLibraries)
           fileDependencies     = true;
           hideLibraries        = ~editorData.showLibraries;
           hideFactoryLibraries = ~editorData.showMathWorksDependencies;
           instanceView         = false;
       else
           fileDependencies     = false;
           hideLibraries        = ~editorData.showLibraries;
           hideFactoryLibraries = ~editorData.showMathWorksDependencies;
           instanceView         = false;
       end % if
   else
       assert(editorData.showInstanceView);

       fileDependencies     = false;
       hideLibraries        = true;
       hideFactoryLibraries = false;
       instanceView         = true;
   end
      
   model.beginChangeSet();
   try
       [depModel,unresolvedModels,cancelled] = findDependencies(query, 'Depth', -1, ...
                                                                       'LookUnderMasks', 'on', ...
                                                                       'HideFactoryLibraries', hideFactoryLibraries, ...
                                                                       'HideLibraries', hideLibraries, ...
                                                                       'InstanceView', instanceView, ...
                                                                       'FileDependencies', fileDependencies, ...
                                                                       'DepModel', model);
   catch ME
       msgbox(ME.message, sprintf('Error finding dependencies:'), 'error');
       model.commitChangeSet();
       cancelled = true;       
       return;
   end % try/catch
   
   model.commitChangeSet();
   
   if(cancelled || ~ishandle(ui) || ~ishandle(tab) )       
       return;
   end   
   
   if(~isempty(unresolvedModels))
       unresolvedModelsStr = sprintf('%s', unresolvedModels{1});

       for i = 2:length(unresolvedModels)
           unresolvedModelsStr = sprintf('%s, %s', unresolvedModelsStr, unresolvedModels{i});
       end % for
       
       msgTitle = xlate('Unresolved References');
       warndlg(sprintf('The following models or libraries could not be resolved:  %s\n\nPlease ensure they are on your path.', ...
                        unresolvedModelsStr), msgTitle);
   end
        
   appModel.beginChangeSet();
   app.clear();  % g392081, make sure to clear here, so only ONE changeset
   app.syncModel(model);  
   applyDotLayout(uiID, tabID); 
   appModel.commitChangeSet();       
    
end

function loc_addLegend(editorData, model, query)
    legend = model.createLegendNode;
    legend.timestamp = datestr(now);
    [~, name] = fileparts(query);
    legend.title = [xlate('Dependency viewer'), ': ',name];
end
