% Copyright 2009 The MathWorks, Inc.

classdef DepViewerUIActions
      
    methods
        function editorData = getEditorData(self, tab) 
            editor = tab.getEditor();
            editorData = editor.getEditorData();
        end
        
        function ui = createWindow(self) 
            manager = DepViewer.DepViewerUIManager;
            
            ui = manager.createUI();
            
            ui.setTitle(xlate('Model Dependency Viewer'));
            ui.show;                                   
        end
        

        function [ui, tab] = createTab(self, ui) 
            tab = ui.createTab();    
            can = tab.getCanvas();
            can.antiAliased = 0;            
        end
        
        function setTabLabel(self, tab, fullFileName) 
            %Set the tab label:
            % If the depdencency viewer was saved as a .dep file, the
            % label is the dep file name. Otherwise, it's the simulink
            % filename. Note: we are not showing full paths (tooltip will
            % be used for full paths)
            
            [~, name, ext] = fileparts(fullFileName);                        
            tab.setLabel([name, ext]);
        end
                
        function open(self, ui)
            if( ui.getTabCount() > 0 )   
                tab = ui.getSelectedTab();
                editorData = self.getEditorData(tab);

                % uigetfile brings up the dialog in the context of pwd.
                % There's no option to explicitly specify the context.
                % changing pwd and restoring it to achieve desired effect.
                % uigetfile is modal, so that should be safe.
                oldPath = pwd;
                if( ~isempty(editorData.lastOpenFileName) )
                    pathStr = fileparts(editorData.lastOpenFileName);
                    if( ~isempty(pathStr) ), cd(pathStr); end                  
                end
            end
            
            [filename, pathname] = uigetfile({'*.dep', 'Dependency Viewer files (*.dep)'; ...
                                              '*.mdl','Simulink Models (*.mdl)'}, ...
                                              xlate('Open...'));
            %restoring path (see above)
            if( ui.getTabCount() > 0 && ~isempty(editorData.lastOpenFileName) )
                cd(oldPath);                   
            end
            
            if(filename==0), return; end
            [fid, errmsg] = fopen([pathname, filename], 'r');

            if fid == -1
                msgId = ['Simulink:DepViewer:','FileOpen'];
                errordlg(sprintf('Error opening file ''%s'': %s', [pathname,filename], errmsg), msgId);
                return;
            end 
            fclose(fid);
                                    
            self.load(ui, [pathname, filename]);            
        end 
        
        function tab = createTabIfNecessary(self, ui, fullFileName) 
            tab = ui.findTabWithQuery(fullFileName);

            if( isempty(tab) )
                % create the tab only if none currently exists:
                tab = ui.createTab();
            end
            %always select the tab
            ui.selectTab(tab.getID());            
        
        end
        
        %This function will add the path of the simulink model file which
        %is displayed in 'tab'. This is required for usability purposes,
        %when a model is loaded with an absolute filepath that is not on 
        %the MATLAB path. The original path is restored the ui is closed
        %for safety and consistency.
        function updateMatlabPath(self, ui, tab)
            %ensuring the model is on the matlab path
            editorData = self.getEditorData(tab);
            p = path;
            pathstr = fileparts(editorData.lastQuery);
            if(isempty(strfind(p, pathstr)))
                addpath(pathstr);
                ui.addPathToRemove(pathstr);
            end
        end
                
        %This function is called when the ui is closed to restore the
        %original MATLAB path.
        function restoreMatlabPath(self, ui) 
            paths = ui.getPathsToRemove();
            for i=1:length(paths)
                pathstr = paths{i};
                rmpath(pathstr);
            end                    
        end
        
        function tab=load(self, ui, fullFileName, varargin)
            tab = 0;
            if(isempty(fullFileName)), return; end
            
            assert( length(varargin) < 2 );
            
            if( ~isempty(varargin) )
                defaultEditorDataValues = varargin{1};
            else
                defaultEditorDataValues.showLibraries            = true;
                defaultEditorDataValues.showFileDependenciesView = true;
                defaultEditorDataValues.showInstanceView         = false;       
            end
            
            %ensuring the file is on the matlab path.
            %This is to ensure "exists" returns the correct value.
            %If 'fullFileName' is not on the path, exists won't return it
            %is a simulink model file, just a normal file instead. We could
            %have determined that ourselves, but we opted to rely on
            %exists.
            
            %The path is immediately restored below.
            %Note that we also have to make sure that the root .mdl file
            %is also on the path (done in updateMatlabPath/restoreMatlabPath).
            origPath = path;
            pathstr = fileparts(fullFileName);
            addpath(pathstr);
            
            tab = ui.findTabWithQuery(fullFileName);
            filetype = exist( fullFileName, 'file' );
            path(origPath);
            if( ~ishandle(tab) && filetype )                
                tab = ui.createTab();
                
                %Setting up the editor data with default values. When the
                %dependency viewer is invoked from simulink (with a .mdl), we want to
                %specify the dependency type to display. So, it is passed
                %in as an argument. If a .dep file is loaded below, it will
                %override these settings.
                editorData = self.getEditorData(tab);
                editorData.showInstanceView         = defaultEditorDataValues.showInstanceView;
                editorData.showFileDependenciesView = defaultEditorDataValues.showFileDependenciesView;
                
                if(isfield(defaultEditorDataValues, 'showLibraries'))
                    editorData.showLibraries            = defaultEditorDataValues.showLibraries;
                end 
                
                self.setTabLabel(tab, fullFileName); 
                ui.selectTab(tab.getID());
                if( eq( filetype, 2) ) %2 -> is a file on the MATLAB path                        
                    success = self.loadDep(ui, tab, fullFileName);
                    
                    if( ~success )
                        ui.removeTab( tab )
                        return;
                    end
                    
                    self.updateMatlabPath(ui, tab);
                end
                
                if( eq( filetype, 4) )               
                    self.loadMdl(ui, tab, fullFileName);
                    self.updateMatlabPath(ui, tab);
                    cancelled = self.refresh(ui, tab);
                    if(cancelled || ~ishandle(ui) || ~ishandle(tab) )
                        if( ishandle(ui) && ishandle(tab) )
                            ui.removeTab(tab);
                        end
                        return;
                    end
                end
                          
                editorData = self.getEditorData(tab);
                editorData.lastOpenFileName = fullFileName;
            else
                if(filetype && eq( filetype, 4)) %exists and is a mdl file on the path 
                    %in this case, there is already a tab showing
                    %'fullFileName'. However, it's possible that we now
                    %want to view a different dependency type, requiring a
                    %refresh.

                    editorData = self.getEditorData(tab);
                    
                    % If showLibraries is not specified in 
                    % defaultEditorDataValues, it should take on whatever
                    % value it already has.  showLibraries may not be set
                    % because instance mode doesn't care about this value
                    % and therefore doesn't set it
                    if(~ isfield(defaultEditorDataValues, 'showLibraries'))
                       defaultEditorDataValues.showLibraries = editorData.showLibraries;
                    end 
                    
                    if ( (editorData.showInstanceView         ~= defaultEditorDataValues.showInstanceView)   || ...
                         (editorData.showLibraries            ~= defaultEditorDataValues.showLibraries)  || ...
                         (editorData.showFileDependenciesView ~= defaultEditorDataValues.showFileDependenciesView) )
                         editorData.showInstanceView         = defaultEditorDataValues.showInstanceView;
                         editorData.showFileDependenciesView = defaultEditorDataValues.showFileDependenciesView;
                         editorData.showLibraries            = defaultEditorDataValues.showLibraries;
                    end
                    cancelled = self.refresh(ui, tab);
                    if(cancelled)
                        return;
                    end
                 end
             end                

            ui.selectTab(tab.getID());
            tab.setDirty(false);
            self.zoomFit(tab);            
        end
        
        function doc = createDomDocument(self, rootName, nodes) 
            tmpName = tempname;
            outFile = fopen(tmpName, 'w');
            fwrite(outFile, ['<',rootName, '></', rootName, '>']);   
            fclose(outFile);
            doc = xmlread(tmpName);
                       
            for i=0:nodes.getLength()-1
                curNode = doc.importNode(nodes.item(i), true);
                docElem = doc.getDocumentElement();
                docElem.appendChild(curNode);                
            end 
            delete(tmpName);
        end
               
        function success = loadDep(self, ui, tab, fullFileName)
            try
                editorDataModel = self.getEditorData(tab).getModel();
                abstractModel   = self.getModel(tab); 

                version = determineDepFileVersion(fullFileName, ... 
                                                  abstractModel.getSignature(), ... 
                                                  editorDataModel.getSignature());
                success = true;



                if version == 3               
                    ma         = GLSM11.ModelArchive;
                    ma.open( fullFileName );

                    %loading the editor data model
                    success = ma.loadModel( 'editorData', editorDataModel );
                    if( ~success ), version = -1; end

                    if( success )
                        %loading the abstract data model
                        success = ma.loadModel( 'abstractData', abstractModel );                                    
                        if( ~success ), version = -1; end
                    end

                    ma.close();                     
                elseif version == 2 

                    fullDom = xmlread(fullFileName);
                    list = fullDom.getElementsByTagName('model'); 
                    editorDataModelTmpName = tempname;
                    editorDataModelDom = self.createDomDocument('model', list.item(0).getElementsByTagName('node') );       
                    xmlwrite( editorDataModelTmpName, editorDataModelDom );

                    % Load the editor's data model
                    editorDataModel.load(editorDataModelTmpName);

                    % Version 2 conversion is taken care of in C++
                    app = tab.getApp();
                    app.loadV2DepFile(fullFileName);

                    delete(editorDataModelTmpName);
                elseif version == 1
                    self.loadLegacyDep_R2007a(ui, tab, fullFileName);                                           
                end

                if version == -1
                    msgId = ['Simulink:DepViewer:','FileOpen'];
                    errordlg(sprintf('Unknown file format ''%s''', fullFileName), msgId);
                    success = false;
                    return;    
                end

                 %lastSaveFileName cannot be trusted! It could have been
                 %renamed since the last save. Must use fullFileName as truth.
                 editorData = self.getEditorData(tab);
                 editorData.lastSaveFileName = fullFileName;  
            catch ME
                msgId = ['Simulink:DepViewer:','FileOpen'];
                errordlg(sprintf('Unknown file format ''%s''', fullFileName), msgId);
                success = false;
                return;                
            end
        end
        

        function fillLegacyNodeData(self, curDepNode, nodeData) 
            name     = nodeData{1}{1};
            x        = nodeData{2}(1);
            y        = nodeData{3}(1);
            width    = nodeData{4}(1);
            height   = nodeData{5}(1); 
            expanded = nodeData{6}(1);
            visible  = nodeData{7}(1);            
            
            curDepNode.position        = [x, y];
            curDepNode.size            = [width, height];
            curDepNode.expanded        = expanded;
            curDepNode.actualSimMode   = 'Normal'; 
            curDepNode.configuredSimMode   = 'Normal'; 
            curDepNode.shortname       = name;
            curDepNode.longname        = name;
            curDepNode.pathToOpen      = name;
            curDepNode.displayLabel    = name;
            curDepNode.pathToHilite    = '';
            curDepNode.pathOnDisk      = which(name);  
            curDepNode.isVisible       = visible;
        end  

        
        function loadLegacyDep_R2007a(self, ui, tab, fullFileName) 
            fid = fopen(fullFileName);
            
            assert( ~eq(fid, -1) );
            
            model = self.getModel(tab);
            model.beginChangeSet();
            
            editorData = self.getEditorData(tab);
            
            editorData.showMathWorksDependencies = false;
            editorData.showLibraries             = true;
            editorData.showInstanceView          = false;
            editorData.showFullPath              = false;
            editorData.showLegend                = true;
            editorData.showFileDependenciesView  = true;
            editorData.showHorizontal            = false;
            editorData.showVertical              = true;            
            
            while (~feof(fid))
                curLine=fgetl(fid);
                [entryType, curLine] = strtok(curLine); %#ok
                switch entryType
                    case 'ModelProps'
                        propsData = textscan(curLine, '%q%q', 1);
                        legend = model.createLegendNode();
                        legend.timestamp = propsData{2}{1};
                        legend.title = ['Dependency viewer: ',propsData{1}{1}];                                                                                               
                    case 'Model'
                        nodeData = textscan(curLine, '%s%n%n%n%n%n%n');
                        curDepNode = model.createModelReferenceDepNode();
                        self.fillLegacyNodeData(curDepNode, nodeData);
                        nodeMap.(nodeData{1}{1}) = curDepNode;
                    case 'Library'
                        nodeData = textscan(curLine, '%s%n%n%n%n%n%n');
                        curDepNode = model.createLibraryDepNode();
                        self.fillLegacyNodeData(curDepNode, nodeData);
                        nodeMap.(nodeData{1}{1}) = curDepNode;
                    case 'Dependency'
                        depData = textscan(curLine, '%s%s%n%n%q');
                        fromNode = nodeMap.(depData{1}{1});
                        toNode = nodeMap.(depData{2}{1});
                        if (~isempty(fromNode) && ~isempty(toNode))
                            dependency = model.createDependency();
                            dependency.resolveLink = false;
                            ptDataCell = textscan(depData{5}{1}, '%n');
                            ptData = ptDataCell{1};
                            xs = [];
                            ys = [];
                            for j=1:length(ptData)/2
                                xs(j) = ptData(j*2-1); %#ok
                                ys(j) = ptData(j*2); %#ok
                            end
                            dependency.path = MG.Path(xs, ys);
                            dependency.manuallyRouted = 1;
                            dependency.connect(fromNode, toNode);
                        end
                end
            end

            editorData.lastSaveFileName = fullFileName;
            model.commitChangeSet();
        end            
        
        function loadMdl(self, ui, tab, fullFileName) 
            model = load_system(fullFileName);    
            if(model) 
                editorData = self.getEditorData(tab);
                editorData.lastQuery = fullFileName;                    
            end        
        end
        
        function save(self, ui, tab)
            editorData = self.getEditorData(tab);
                                     
            if(isempty(editorData.lastSaveFileName))
                self.saveAs( ui, tab )
            else
                self.doSave(ui, tab, editorData.lastSaveFileName);    
            end
                               
        end
        
        function saveAs(self, ui, tab)
            % uiputfile brings up the dialog in the context of pwd.
            % There's no option to explicitly specify the context.
            % changing pwd and restoring it to achieve desired effect.
            % uiputfile is modal, so that should be safe.
            editorData = self.getEditorData(tab);
            oldPath = pwd;
            if( ~isempty(editorData.lastSaveFileName) )
                pathStr = fileparts(editorData.lastSaveFileName);
                cd(pathStr);                    
            end             
            
            [filename, pathname] = uiputfile('*.dep', xlate('Save Dependency View As...')); 
            if(filename==0), return; end
            [fid, errmsg] = fopen([pathname, filename], 'w');

            if fid == -1
                msgId = ['Simulink:DepViewer:','FileOpen'];
                errordlg(sprintf('Error creating file ''%s'': %s', [pathname,filename], errmsg), msgId);
                return;
            end   
            fclose(fid);
            
            %restoring path (see above)
            if( ~isempty(editorData.lastSaveFileName) )
                cd(oldPath);                   
            end             
   
            self.doSave(ui, tab, [pathname, filename]);            
        end
        
        function doSave(self, ui, tab, fullFileName) 
            %Here, we need to combine both the model and the editor
            %data into a single file.
            model           = self.getModel(tab);
            editorData      = self.getEditorData(tab).getModel();
            
            ma = GLSM11.ModelArchive;
            ma.open( fullFileName );
            ma.addModel( 'abstractData', model );                                    
            ma.addModel( 'editorData', editorData );
            ma.close();
        end
        
        function model = getModel(self, tab) 
            app = tab.getApp();
            model = app.getModel();
        end
        
        function closeAll(self, ui, tab) 
            model = self.getModel(tab);          
            children = model.getNodes();
            depNodes = find(children, '-isa', 'DepViewer.DepNode');

            % Retrieve the list of all models that are open in the system
            openMdls = find_system('SearchDepth',0, 'type','block_diagram');
            for i = 1:length(depNodes)
                thisMdl = depNodes(i).pathToOpen;
                fIdx = strmatch(thisMdl,openMdls,'exact');
                if ~isempty(fIdx)
                    isDirty   = get_param(thisMdl,'dirty');
                    if strcmp(isDirty, 'off')
                        close_system(thisMdl, 0);
                    else  %model is modified, ask user what to do
                        msg = sprintf(['The "%s" model has unsaved changes. Select: ',...
                                       '\n- "Save and Close" to save and close the model.',...
                                       '\n- "Close" to close the model without saving it.',...
                                       '\n- "Cancel" to leave the model open.'], thisMdl);
                        ButtonName=questdlg(msg, ...
                                            'Attention:', ...
                                            'Save and Close',...
                                            'Close',...
                                            'Cancel',...
                                            'Save and Close');
                        switch ButtonName,
                            case 'Save and Close', 
                                close_system(thisMdl, 1);
                            case 'Close',
                                close_system(thisMdl, 0);
                            case 'Leave open',
                                % do nothing
                        end % switch
                    end
                    newOpenMdls = {};
                    for j=1:length(openMdls)
                        if( ~eq(j,fIdx) )
                            newOpenMdls = [newOpenMdls;openMdls{j}]; %#ok
                        end
                    end
                    openMdls = newOpenMdls;
                end 
            end        
        end
        
        function cancelled = refresh(self, ui, tab)      
            editorData = self.getEditorData(tab);
            cancelled = findDependenciesAndUpdateEditor( editorData.lastQuery, ui.getID(), tab.getID() ); 
                        
            self.zoomFit(tab);
        end
        
        function relayout(self, ui, tab) 
            applyDotLayout( ui.getID(), tab.getID() );        
        end
        
        function setVerticalOrientation(self, ui, tab)
            editorData = self.getEditorData(tab);
            if( ~editorData.showVertical )       
                editorData.showVertical = true;
                editorData.showHorizontal = false;
                self.relayout( ui, tab );  
                self.zoomFit(tab);
            end        
        end
        
        function setHorizontalOrientation(self, ui, tab)
            editorData = self.getEditorData(tab);
            if( ~editorData.showHorizontal )       
                editorData.showHorizontal = true;
                editorData.showVertical = false;
                self.relayout( ui, tab );
                self.zoomFit(tab);
            end            
        end
         
        function menuState = getMenuStateToUndo(self, editorData) 
            menuState.showMathWorksDependencies = editorData.showMathWorksDependencies;
            menuState.showLibraries             = editorData.showLibraries;
            menuState.showInstanceView          = editorData.showInstanceView;
            menuState.showFullPath              = editorData.showFullPath;
            menuState.showLegend                = editorData.showLegend;
            menuState.showFileDependenciesView  = editorData.showFileDependenciesView;
            menuState.showHorizontal            = editorData.showHorizontal;
            menuState.showVertical              = editorData.showVertical;
        end
        
        function restoreMenuState(self, editorData, menuState) 
            editorData.showMathWorksDependencies = menuState.showMathWorksDependencies;
            editorData.showLibraries             = menuState.showLibraries;
            editorData.showInstanceView          = menuState.showInstanceView;
            editorData.showFullPath              = menuState.showFullPath;
            editorData.showLegend                = menuState.showLegend;            
            editorData.showFileDependenciesView  = menuState.showFileDependenciesView;
            editorData.showHorizontal            = menuState.showHorizontal;
            editorData.showVertical              = menuState.showVertical;
        end
        
        function showMathWorksDependencies(self, ui, tab)
            editorData = self.getEditorData(tab);
            menuState = self.getMenuStateToUndo(editorData);
            editorData.showMathWorksDependencies = ~editorData.showMathWorksDependencies;
            if(editorData.showMathWorksDependencies)
                editorData.showLibraries = 1;
            end 
            cancelled = self.refresh(ui, tab);
            if(cancelled)
                self.restoreMenuState(editorData, menuState);
            end
            
        end
        
        function showLibraries(self, ui , tab)
            editorData = self.getEditorData(tab);
            menuState = self.getMenuStateToUndo(editorData);            
            editorData.showLibraries = ~editorData.showLibraries;
            if(~editorData.showLibraries)
                editorData.showMathWorksDependencies = 0;
            end 
            cancelled = self.refresh(ui, tab); 
            if(cancelled)
                self.restoreMenuState(editorData, menuState);
            end            
        end
        
        function showLegend(self, ui, tab) 
            editorData = self.getEditorData(tab);           
            editorData.showLegend = ~editorData.showLegend;   
            
            app = tab.getApp();
            model = app.getModel();
            children = model.getNodes();
            legend = find(children, '-isa', 'DepViewer.LegendNode');
            
            %should be only one!
            assert( eq(length(legend),1) );
            
            legend.isVisible = editorData.showLegend;
                        
        end
        
        
        function selectModelRefDependenciesInstanceView(self,ui ,tab)
            editorData = self.getEditorData(tab);
            
            if( ~editorData.showInstanceView )
                menuState = self.getMenuStateToUndo(editorData);
                editorData.showInstanceView = true;
                editorData.showFileDependenciesView = false;

                cancelled = self.refresh( ui, tab );
                if(cancelled)
                    self.restoreMenuState(editorData, menuState);
                end                  
            end     
        end
        
        function selectFileDependencies(self,ui ,tab)
            editorData = self.getEditorData(tab);
            
            if( ~editorData.showFileDependencies )
                menuState = self.getMenuStateToUndo(editorData);
                editorData.showInstanceView = false;
                editorData.showFileDependenciesView = true;
                
                cancelled = self.refresh( ui, tab );
                if(cancelled)
                    self.restoreMenuState(editorData, menuState);
                end 
              
            end     
        end
        
        function showFullPath(self, ui, tab)
            editorData = self.getEditorData(tab);            
            editorData.showFullPath = ~editorData.showFullPath;
            self.relayout(ui,tab);        
        end
        
        function help(self, ui) 
            helpview([docroot '/mapfiles/simulink.map'],'dependency_viewer');        
        end
        
        function about(self, ui) 
            daabout('simulink');
        end
        
        function close(self, ui)
            self.restoreMatlabPath(ui);
            manager    = DepViewer.DepViewerUIManager;            
            manager.destroyWindow(ui.getID());
            
        end
        
        function print(self, ui, tab) 
            %Bring up the print dialog, which was properly setup with the
            %tab canvas.
            tab.printTab(); 
        end
        
        function zoomFit(self, tab) 
            pause(0.15); % TODO: Ugly! Make this go away!  Pause gives chance for bounds to update
            if( ~ishandle(tab) ), return; end            
            tab.zoomFit(); 
        end
        
    end

end
