% Copyright 2007 The MathWorks, Inc.
%
% Dependency Viewer
% 
% Input (optional): 
%          ModelName or ModelHandle
%          'FileDependenciesIncludingLibraries', booleanFlag
%          'FileDependenciesExcludingLibraries', booleanFlag
%          'ModelReferenceInstance', booleanFlag
%
% Output: [ui, tab] 
%
function [ui, tab] = depview(varargin)  

    ui = []; % Ensure we have defaults if we error out
    tab = []; 
         
    argParser = inputParser;
    argParser.addOptional('models', {}, @loc_validateModels);
    argParser.addParamValue('SkipLicenseCheck',                   false,  @islogical);
    argParser.addParamValue('FileDependenciesIncludingLibraries', false,  @islogical);
    argParser.addParamValue('FileDependenciesExcludingLibraries', false,  @islogical);
    argParser.addParamValue('ModelReferenceInstance',             false,  @islogical);    
    
    try        
        argParser.parse(varargin{:});
    catch ME
        errid = ME.identifier;
        if(isempty(regexp(errid, '^MATLAB:InputParser', 'once' )))
            rethrow(ME);
        else
            newException = MException('Simulink:DependencyViewer:ArgumentError', 'Usage: depview(modelName) or depview(modelHandle).');
            throw(newException);
        end
    end
    
    fileDependenciesIncludingLibraries = argParser.Results.FileDependenciesIncludingLibraries;
    fileDependenciesExcludingLibraries = argParser.Results.FileDependenciesExcludingLibraries;
    modelReferenceInstance             = argParser.Results.ModelReferenceInstance;
    
    usedDefault = argParser.UsingDefaults;
    if( (~ isempty(find(strcmp('FileDependenciesIncludingLibraries', usedDefault), 1)) ) && ...
        (~ isempty(find(strcmp('FileDependenciesExcludingLibraries', usedDefault), 1)) ) && ...
        (~ isempty(find(strcmp('ModelReferenceInstance', usedDefault), 1)) ) )
        fileDependenciesIncludingLibraries = true;
    end % if

    if((fileDependenciesIncludingLibraries + fileDependenciesExcludingLibraries + modelReferenceInstance) > 1)
        error('Simulink:DependencyViewer:ModeError', 'More than one mode specified');  % xxx
    end % if
    
    
    models = argParser.Results.models;    
    if(~iscell(models))
        models = {models};
    end
    for j=1:length(models)        
        models{j} = loc_getMdlName(models{j});
    end
            
    if(isempty(models))
        models = {''};
    end
    
    %support multiple roots later (editor data needs to support vector of
    %strings.
    query = models{1};
    
    %Getting a unique representation of the query:
    %Transform "../foo.dep" -> C:\blah\foo.dep
    %          "vdp"        -> C:\...\matlab\...\vdp.mdl
    query = loc_getAbsolutePath(query);
    
    %A simple MCOS class with no state (can be seen as singleton)
    %it exposes the API of the dependency viewer UI (open, save, refresh,
    %etc). Basically, there is a function for every menu item in
    %DepViewerActions. 
    uiactions = DepViewerUIActions; 
    
    %The manager owns the UI instances. Used to cleanup the UIs
    %when they are closed by users. Also provide a small API acting
    %on the set of UI.
    manager   = DepViewer.DepViewerUIManager;
    
    %g484676
    if( manager.isPrinting() )
        msg = 'The Dependency Viewer cannot be used until the print operation is completed or cancelled.';
        warning('depView:CurrentlyPrinting', msg);
        return;
    end
    
    if(manager.hasDefaultUI())
        ui = manager.getDefaultUI();
    else
        ui = uiactions.createWindow();
    end
    
    ui.show();
        
    if(fileDependenciesIncludingLibraries)
        assert(~fileDependenciesExcludingLibraries);
        assert(~modelReferenceInstance);

        editorData.showLibraries            = true;
        editorData.showFileDependenciesView = true;
        editorData.showInstanceView         = false;       
    elseif(fileDependenciesExcludingLibraries)
        assert(~modelReferenceInstance);

        editorData.showLibraries            = false;
        editorData.showFileDependenciesView = true;
        editorData.showInstanceView         = false;       
    else
        assert(modelReferenceInstance);

        editorData.showFileDependenciesView = false;
        editorData.showInstanceView         = true;       
    end % if;
    
    %load will determine the type of query we are facing:
    % 1) a .mdl file 
    % 2) a .dep file 
    tab = uiactions.load(ui, query, editorData);     
        
end

function query = loc_getAbsolutePath(query)
    if(isempty(query)), return; end
    filetype = exist(query, 'file');
    if(filetype)
        if( eq( filetype, 2) ) %2 -> is a file                   
            [success, data, id] = fileattrib(query);
            if(success)
                query = data.Name;
            else
                warning(['depView:', id], [data, ', ', query]);
                query = '';
            end
        end

        if( eq( filetype, 4) )  %4 -> is a mdl file on the path 
            whichQuery = which(query);
            if( isempty(strmatch('new Simulink model', whichQuery)) )
                query = whichQuery;
            end
        end         
    else
        warning('depView:FileNotFound', ['File: ', query, ' was not found.']);
        query = '';
    end
end

function mdlName=loc_getMdlName(mdl)
    try
        if(ischar(mdl))
            mdlName=strtrim(mdl);
            return;
        end
        if(~isnumeric(mdl) && ishandle(mdl))
            %udd handle
            mdlHndl = mdl.handle;
            mdlName = loc_getMdlName(get(mdlHndl, 'Name'));
            return;
        end

        if(isnumeric(mdl) && ishandle(mdl))
            %matlab handle (was already a handle!)
            mdlHndl = mdl;
            mdlName = loc_getMdlName(get(mdlHndl, 'Name'));
            return;
        end
    catch %#ok<CTCH>
    end
    mdlName = 0;
end

function valid = loc_validateModels(models)
    valid = true;
    if(~iscell(models))
        models = {models}; 
    end
    for j=1:length(models)
        if(~ischar(models{j}) && ~ishandle(models{j}))
            valid = false;
        end
    end
end
