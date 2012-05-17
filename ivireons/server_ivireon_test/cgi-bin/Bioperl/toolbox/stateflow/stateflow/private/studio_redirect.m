function output = studio_redirect(fcn, varargin)
    output = [];
    switch fcn
      
      case 'ViewContent'
        oid = varargin{1};
        view_content(oid);
      
      case 'Open'
        % Wish I could throw to "assert" here for number of args
        % But, this is not allowed unless we create message IDs instead
        % This code causes test failures even though it does not run!   
        open_object(varargin{1});      
      
      case 'Select'
        % chart is arg #1, but we can ignore it here
        oids = varargin{2};
        select(oids);
      
      case 'FitToView'
        if (nargin < 3 || isempty(varargin{2}))
            fit_to_view_subviewer(varargin{1});
        else
            oids = varargin{2};
            fit_to_view_objects(oids);
        end

      case 'SetZoomFactor'
        set_zoom_factor_subviewer(varargin{1},varargin{2});
      
      case 'GetZoomFactor'
        output = get_zoom_factor_subviewer(varargin{1});
      
      case 'SelectedObjectsIn'
        output = selected_objects_in(varargin{1});

      case 'CurrentEditorId'
        output = get_current_chart;

      case 'GetCurrentObject'
        % despite the confusing name, this function is actually supposed
        % to return the selection list!  That is how sf('GetCurrentObject')
        % is implemented, so we must follow suit here
        output = 0;
        svid = get_current_subviewer;
        if (svid ~= 0) 
            output = selected_objects_in(svid);
            if (isempty(output))
                output = 0;
            end
        end

      case 'ClearChartUndoStack'
        clear_undo_stack_for_chart(varargin{1});
        
      case 'ClearUndoStack'
        % This function is terribly named, but we must keep consistent here with
        % sf behavior.  IF the passed-in object is a data with function input or 
        % function output scope, then it will clear the undo stack in the 
        % associated chart.  Otherwise it will do nothing!
        clear_undo_stack_for_fcn_io_data(varargin{1});

      case 'GetUndoStackSize'
        output = get_maximum_undo_stack_size;
        
      case 'SetUndoStackSize'
        set_maximum_undo_stack_size(varargin{1});
        output = get_maximum_undo_stack_size;

      case 'Copy'
        copy_from_chart(varargin{1});
      
    end
end

function copy_from_chart(chartid)
% There is some ambiguity here because classic SF only allows
% one subviewer per chart to be open at once.  We allow more 
% than one.  So, there may be any number of selection lists
% for a single chart.  So, we'll do the following:
% If the current editor is viewing in the given chart, then 
% copy from that editor.  Otherwise, copy from the top-level
% of the given chart, if open.  Otherwise, do nothing.

    svid = get_current_subviewer;
    currentChartId = get_chart_for_object(svid);
    if (currentChartId == chartid)
        copy_from_editor(get_current_editor);
    else
        mdpair = StateflowDI.Util.getSubviewer(chartid);
        diagram = mdpair.diagram;
        if (~isempty(diagram) && diagram.isValid)
            [~, editor] = find_editor(diagram);
            if (~isempty(editor))
                copy_from_editor(editor)
            end
        end
    end
end


function copy_from_editor(editor)
    domain = editor.menuDomain;
    if (domain.canCopy)
        domain.doCopy;
    end
end


function mss = get_maximum_undo_stack_size
    
    % It's meaningless to have an undo size not associated with a model in M3I
    % Nevertheless, the old code defaults to 100, so use that here as well
    mss = 100;

    % The old code guaranteed that all charts had the same undo stack length
    % That's not possible in M3I-land.  Either they are all the same, or they're
    % not.  In the latter case, there's no right answer.
    % So, just return the stack length of the first chart.  That will give the 
    % right answer in the former case, and a reasonable answer in the latter.
    allCharts = find(sfroot, '-isa', 'Stateflow.Chart');
    % Just return the length of the first one
    if (~isempty(allCharts))
        mdpair = StateflowDI.Util.getSubviewer(allCharts(1).Id);
        mss = mdpair.model.getMaximumUndoStackLength;
    end    
end

function set_maximum_undo_stack_size(newSize)
    % Set all the charts' undo stack sizes at once
    % This is what the old code does
    allCharts = find(sfroot, '-isa', 'Stateflow.Chart');
    for i=1:length(allCharts)
        chartudd = allCharts(1);
        mdpair = StateflowDI.Util.getSubviewer(chartudd.Id);
        mdpair.model.setMaximumUndoStackLength(newSize);
    end
end

function clear_undo_stack_for_chart(chartid)
    mdpair = StateflowDI.Util.getSubviewer(chartid);
    model = mdpair.model;
    model.clearUndoStack;
end

function clear_undo_stack_for_fcn_io_data(dataid)
    if data_is_fcn_io(dataid)
        dataudd = idToHandle(sfroot, dataid);
        dataowner = dataudd.up;
        chartid = get_chart_for_object(dataowner.Id);
        clear_undo_stack_for_chart(chartid);        
    end
end

function isfio = data_is_fcn_io(dataid)
% The concept of "function IO" is modelled in neither
% M3I nor UDD.  So, we need to use the sf('get') API.
% We don't want to add this to the model, because this
% clear_undo_stack_for_fcn_io_data is such a ridiculous 
% use case.  Hopefully, we can just get rid of it.
    isfio = false;
    if (sf('get', dataid, '.isa') == 8)
        scopeid = sf('get', dataid, '.scope');
        isfio = ( (scopeid == 8) || (scopeid == 9) );
    end
end


% If an editor is open for the given subviewer, return the list of SF IDs representing 
% that editors selection list.  Returns [] if no editor is open, or if the selection list
% is empty
function ids = selected_objects_in(svid)
    ids = [];
    mdpair = StateflowDI.Util.getSubviewer(svid);    
    [~, editor] = find_editor(mdpair.diagram);
    if (~isempty(editor))
        m3is = editor.getSelection;
        ids = M3Is_to_ids(m3is);
    end
end


% Open an editor to the given subviewer, and rezoom so all contained objects are visible
function fit_to_view_subviewer(svid)
    editor = view_content(svid);
    editor.getCanvas.zoomToSceneRect;
end

% Open an editor to the given subviewer, and zoom 
function set_zoom_factor_subviewer(svid, zoom)
    editor = view_content(svid);
    editor.getCanvas.Scale = zoom;
end

% Open an editor to the given subviewer, and get the zoom factor
function zoomFactor = get_zoom_factor_subviewer(svid)
    editor = view_content(svid);
    zoomFactor = editor.getCanvas.Scale;
end

% Open an editor, and zoom in so that the given list of objects
% are fit to view
function fit_to_view_objects(oids)
    editor = open_editor(oids);
    m3is = ids_to_M3Is(oids);
    
    % Note that the following code could easily be put in GLUE
    viewRegion = get_boundaries(m3is(1));
    for i=2:length(m3is)
        bb = get_boundaries(m3is(i));
        viewRegion = [  min(viewRegion(1), bb(1)) ...
                        min(viewRegion(2), bb(2)) ...
                        max(viewRegion(3), bb(3)) ...
                        max(viewRegion(4), bb(4)) ];
    end
    offset = 60; % Avoid scrollbars if possible by zooming out a bit more
    size = viewRegion(3:4)-viewRegion(1:2);
    sceneRect = [viewRegion(1) - offset, viewRegion(2) - offset, size(1) + 2*offset, size(2) + 2*offset];
    canvas = editor.getCanvas;
    canvas.showSceneRect(sceneRect);
    
end


% Get the boundaries of an M3I object in [x1,y1,x2,y2] format
function bb = get_boundaries(m3iObj)
    bb = [m3iObj.absPosition, m3iObj.absPosition + m3iObj.size];
end


% Get a collection of M3I objects representing the objects with the
% given IDs.  This is only guaranteed to work after an editor is 
% open on these objects
function m3is = ids_to_M3Is(ids)
    m3is = [];
    for i=1:length(ids);
        m3is = [m3is, StateflowDI.Util.getDiagramElement(ids(i))];  %#ok
    end
end

% Get the backend object ids of the given M3I Stateflow object
function ids = M3Is_to_ids(m3is)
    ids = zeros(1, m3is.size);
    for i=1:m3is.size
        ids(i) = M3I_to_id(m3is.at(i));
    end
end


function id = M3I_to_id(m3i)
    id = m3i.backendId;
end

% First ensure an editor is open than is displaying the given objects,
% then select the objects (and only those objects)
function select(oids)
    editor = open_editor(oids);
    editor.clearSelection;
    for i=1:length(oids)
        objm3i = StateflowDI.Util.getDiagramElement(oids(i));
        if( ~isa(objm3i, 'StateflowDI.Subviewer') )
            editor.select(objm3i.asImmutable);
        end
    end    
end


function open_object(objectId)
    % If state is a subchart...
    if( is_subcharted_state(objectId) )
        view_content(objectId);
        fit_to_view_subviewer(objectId);
    else 
        open_editor(objectId);
        select(objectId);
        fit_to_view_objects(objectId);
    end    
end

function isSubchart = is_subcharted_state(objectId)
    isSubchart = false;
    if( sf('get', objectId,'.isa') == sf('get','default','state.isa') ) % objectId isa Stateflow.State
        if( sf('get', objectId, '.superState') == 2 ) % superState == SUBCHART
            if( sf('get', objectId, '.type') ~= 2 ) % NOT a function
                isSubchart = true;
            end
        end
    end
end

% Given a list of ids all at the same subviewer level,
% ensure that an editor for that level is visible
% This will reuse existing editors/studios where possible,
% and will open them as need be
function editor = open_editor(objIdList)
    svid = get_subviewer_id(objIdList);
    editor = view_content(svid);
end

% View content means "show me the insides of this subviewer"
% even if ordinarily, the insides would be hidden, for example
% if it's a truth table, really show the contents, and don't open
% the TT editor
function editor = view_content(subviewerId)
    mdpair = StateflowDI.Util.getSubviewer(subviewerId);
    [studio, editor] = find_editor(mdpair.diagram);
    if (isempty(studio))
        % No currently open studio... we'll have to open one
        objudd = idToHandle(sfroot, subviewerId);
        while (~isa(objudd, 'Simulink.BlockDiagram'))
            objudd = objudd.up;
        end
        open_system(objudd.Name);
        [studio, editor] = find_editor(mdpair.diagram);
    end
    
    % NOTE: need to open editor even if not empty because we might be
    % viewing a different level of the model when this is called
    editor = studio.App.openEditor(mdpair.diagram);
    studio.show;
end

function chartid = get_current_chart
    chartid = 0;
    svid = get_current_subviewer;
    if (~isempty(svid) && svid ~= 0)
        chartid = get_chart_for_object(svid);
        if (isempty(chartid))
            chartid = 0;
        end
    end
end

function chartid = get_chart_for_object(objid)
    objudd = idToHandle(sfroot, double(objid));
    if (isa(objudd, 'Stateflow.Chart'))
        chartudd = objudd;
    else
        chartudd = objudd.Chart;
    end
    chartid = chartudd.Id;
end
    
function svid = get_current_subviewer
    svid = 0;
    editor = get_current_editor;
    if (~isempty(editor))
        diagram = editor.getDiagram;
        if (isa(diagram, 'StateflowDI.Subviewer'))
            svid = M3I_to_id(diagram);
        end
    end
end

function editor = get_current_editor
    editor = [];
    bdname = gcs;
    if (~isempty(bdname))
        allStudios = DAS.Studio.getAllStudios;
        for i=1:length(allStudios)
            thisStudio = allStudios{i};
            allTabs = thisStudio.getTabComponents;
            tabIndex = thisStudio.getCurrentTab;
            thisEditor = allTabs{tabIndex+1};  % plus 1 to convert to Matlab 1-based indexing
            if (isa(thisEditor, 'GLUE2.Editor'))
                currentDiagram = thisEditor.getDiagram;
                currentBDName = bd_name_from_diagram(currentDiagram);
                if (strcmp(currentBDName, bdname))
                    editor = thisEditor;
                    return;
                end
            end
        end                    
    end
end
    


% Tries to find the studio and editor associated with the given diagram
% 'studio' will be empty if there is no Simulink studio currently open
% 'editor' will be empty if none of the Simulink studios is currently
%    editing the given diagram
%
function [studio, editor] = find_editor(diagram)
    % If we ever change the "one studio per Simulink model" rule, we need to change the 'true' to 'false'        
    [studio, editor] = find_editor_optional_optimization(diagram, true);
end





% Searches for an editor that is currently operating on the given diagram
% This function can optionally by optimized by telling it to assume that only
% one block digram will be open in a single studio (so we don't have to actually
% check all the tabs in a studio, if that studio is operating on a different
% block diagram)
% If a matching editor is found, then the studio and editor are returned.
% If no editor is found, but there is a studio opened for this block diagram,
%   then 'editor' is returned empty, but 'studio' is filled
% If no studio is operating on this diagram, then both return values will be empty
function [studio, editor] = find_editor_optional_optimization(diagram, assumeOneBlockDiagramPerStudio)
    studio = [];
    editor = [];
    allStudios = DAS.Studio.getAllStudios;
    for i=1:length(allStudios)
        thisStudio = allStudios{i};
        matchingStudio = [];
        if (isa(thisStudio.App, 'SLM3I.StudioApp') && thisStudio.App.topLevelDiagram.isvalid)
            % Okay, this studio is a candidate
            allComponents = thisStudio.getTabComponents;
            for j=1:length(allComponents)
                thisComponent = allComponents{j};
                if (isa(thisComponent, 'GLUE2.Editor'))
                    editor = thisComponent;
                    thisDiagram = thisComponent.getDiagram;
                    if (thisDiagram == diagram)
                        % Found a perfect match
                        studio = thisStudio;
                        editor = thisComponent;
                        return;
                    end
                    
                    % The editor is not an exact match, but is the studio a candidate?
                    if (isempty(matchingStudio))
                        if (diagrams_share_block_diagram(thisDiagram, diagram))
                            % Same block diagram -> use this studio
                            % But, keep looping looking for an exact-match tab
                            matchingStudio = thisStudio;
                        elseif (assumeOneBlockDiagramPerStudio)
                            % Different block diagram, so under the optimizing assumption, 
                            % we don't want to bother looking at the other tabs in this studio
                            break;
                        end
                    end                    
                            
                end
            end
        end

        
        if (~isempty(matchingStudio))
            studio = matchingStudio;
        
            % If we make this optimizing assumption...
            if (assumeOneBlockDiagramPerStudio)       
                % ... then don't bother checking any more studios
                return;
            end
            % ... otherwise, keep looking for an exact match
        end
        
    end    
end

% Tells if two SL/SF diagrams are in the same block diagram
function shared = diagrams_share_block_diagram(diagram1, diagram2)
    name1 = bd_name_from_diagram(diagram1);
    name2 = bd_name_from_diagram(diagram2);
    shared = strcmp(name1, name2);
end


% For any Simulink/Stateflow diagram, get the name of the associated block diagram
function bdName = bd_name_from_diagram(diagram)
    fullName = diagram.fullName;
    slashpos = strfind(fullName, '/');
    if (isempty(slashpos))
        bdName = fullName;
    else
        bdName = fullName(1:slashpos-1);
    end
end


% Returns the ID number of the Stateflow subviewer that all of the
% incoming objectids share.  If the objects are at different subviewer
% levels, this function will not work
function subviewerid = get_subviewer_id(objIdList)
    svudd = [];
    for i=1:length(objIdList)
        objid = objIdList(i);
        objudd = idToHandle(sfroot, objid);
        if( isa(objudd, 'Stateflow.Chart') )
            thissv = objudd;
        else
            thissv = objudd.Subviewer;
        end
        if (isempty(svudd))
            svudd = thissv;

        % Wish I could throw to "assert" here
        % But, this is not allowed unless we create message IDs instead
        end
    end
    subviewerid = svudd.Id;
end


