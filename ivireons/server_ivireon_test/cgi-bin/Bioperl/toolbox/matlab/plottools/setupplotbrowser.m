function setupplotbrowser (fig, plotbrowser)
% This undocumented function may be removed in a future release.

% This is a utility function used by the plot browser.

% Copyright 2004-2008 The MathWorks, Inc.

% "setupplotbrowser" is called by the PlotBrowser constructor.  First it
% walks the HG hierarchy for the given figure, picking out axes,
% data-related axes children, and UIPanels, and building a tree structure
% on the Java side that roughly mirrors the HG hierarchy.
% 
% Then it sets up event listeners on those HG objects -- additions,
% deletions, and property changes.  These listeners maintain the Java-side
% tree structure to keep it in sync with the HG hierarchy.  There are some
% other odd events it listens to as well, to account for vagaries in the
% way HG works:  axes title changes, color changes to bar and area plots,
% PlotDone events, and paste events.


if feature('HGUsingMATLABClasses')
    setupplotbrowserHGUsingMatlabClasses(fig, plotbrowser);
    return;
end

    allPropNames = getplotbrowserproptable;
    
    % Special case listeners, stored as a struct array.
    % These are used when adding listeners to objects that appear in
    % the plot browser.
    propSpecialListeners = struct;
    propSpecialListeners(1).Class = 'specgraph.barseries';
    propSpecialListeners(1).Event = 'BarColorChanged';
    propSpecialListeners(1).Callback = {@barColorSetCallback};
    propSpecialListeners(1).RecursionLimit = 0;

    propSpecialListeners(2).Class = 'specgraph.areaseries';
    propSpecialListeners(2).Event = 'AreaColorChanged';
    propSpecialListeners(2).Callback = {@barColorSetCallback};
    propSpecialListeners(2).RecursionLimit = 0;
      
    if isempty(fig) || ~ishandle(fig)
        return;
    end
    
    % The initial batch of listeners are structural.  They listen for added and
    % removed axes and uipanels, plots being made, and pastes being performed:

    createListener (fig, 'ObjectChildAdded', {@figChildAddedCallback}, 'FigChildAddedLsnr',0);
    createListener (fig, 'ObjectChildRemoved', {@figChildRemovedCallback}, 'FigChildRemovedLsnr',1);
    plotmgr = getappdata (fig, 'PlotManager');
    if isempty(plotmgr)
        plotmgr = graphics.plotmanager;
        setappdata (fig, 'PlotManager', plotmgr);
    end 
    createListener (plotmgr, 'PlotFunctionDone', {@figPastePlotDoneCallback}, 'PlotFunctionDoneLsnr',0);
    createListener (plotmgr, 'PlotEditPaste', {@figPastePlotDoneCallback}, 'PlotEditPasteLsnr',0);


    createListener (fig, 'ObjectBeingDestroyed', {@objDestroyedCallback}, 'ObjDestroyedLsnr', 0);

    % Other listeners will be dynamically created and assigned to the figure
    % children (axes and uipanels).  That's done in the callbacks which are
    % subfunctions of this function, such as "figChildAddedCallback."

    % Walk through the HG containment tree (if there are any children
    % already in the figure) and build the PlotBrowser's tree model.  And
    % that's it.  The rest of this function is all subfunction definitions.
    
    buildUpModel (fig);

    %-------------------------------
    function buildUpModel (parent)
    % Recursively constructs the subtree of the PlotBrowser's tree model
    % rooted at this parent, *not* including the parent itself.
    children = get (parent, 'children');
    for i = length(children):-1:1  % walk backwards through children for correct order
        child = children(i);
        if (isa (handle(child), 'scribe.colorbar')) || (isa (handle(child), 'scribe.legend'))
            continue;
            
        elseif isa(handle(child), 'hg.uipanel')
            if (strcmpi (get (child, 'HandleVisibility'), 'off') == 1)
                continue;
            end 
            panel = child;
            if (plotbrowser.hasProxyAlready (java(handle(panel))))
                continue;
            end
            % then add figure-like listeners to catch axes additions
            plotbrowser.addUIPanelProxy (java(handle(panel)), java(handle(parent)));
            updatePropertiesForObject (handle(panel));
            createListener (panel, 'ObjectChildAdded', {@figChildAddedCallback}, 'ObjectChildAddedLsnr',0);
            createListener (panel, 'ObjectChildRemoved', {@figChildRemovedCallback}, 'ObjectChildRemovedLsnr',1);

            % createListener (panel, 'ObjectBeingDestroyed', {@objDestroyedCallback}, 'ObjDestroyedLsnr',0);
            createPropertyListenersForObject (handle(panel));
            buildUpModel (panel);
            
        elseif isa (handle(child), 'hg.axes')
            if (strcmpi (get (child, 'HandleVisibility'), 'off') == 1)
                continue;
            end
            axes = child;
            if (plotbrowser.hasProxyAlready (java(handle(axes))))
                continue;
            end

            createListener (axes, 'ObjectChildAdded', {@axesChildAddedCallback}, 'ObjectChildAddedLsnr',0);
            createListener (axes, 'ObjectChildRemoved', {@axesChildRemovedCallback}, 'ObjectChildRemovedLsnr', 1);

            createPropertyListenersForObject (handle(axes));
            title = get (axes, 'Title');

            createPropertyListener (title, 'String', {@titlePropertySetCallback, axes});
            plotbrowser.addAxesProxy (java(handle(axes)), java(handle(parent)), java(handle(title)));
            updatePropertiesForObject (handle(axes));
            
            % Create and display proxies for axes children
            refreshAxes(axes);
        end
    end
    end
        


    % Callback functions start here.

    %-------------------------------
    function figChildAddedCallback (parent, childEventData)  %#ok<INUSL>
    
    child = childEventData.Child; 
    parent = childEventData.source;
    if (isa (child, 'scribe.colorbar')) ...
        || (isa (child, 'scribe.legend')) ...
        || (isa (child, 'scribe.scribeuaxes'))
        return;
        
    elseif isa (child, 'hg.axes') 
        if (strcmpi (get (child, 'HandleVisibility'), 'off') == 1)
            return;
        end
        axes = child;
        % Standard create-an-axes-on-the-figure code path:
        if (plotbrowser.hasProxyAlready (java(handle(axes))))
            return;
        end

        createListener (axes, 'ObjectChildAdded', {@axesChildAddedCallback}, 'ObjectChildAddedLsnr',0);
        createListener (axes, 'ObjectChildRemoved', {@axesChildRemovedCallback}, 'ObjectChildRemovedLsnr',1);
        createPropertyListenersForObject (handle(axes));
        title = get (axes, 'Title');
        createPropertyListener (title, 'String', {@titlePropertySetCallback, axes});

        plotbrowser.addAxesProxy (java(handle(axes)), java(handle(parent)), java(handle(title)));
        updatePropertiesForObject (handle(axes));
    elseif isa(child, 'hg.uipanel')
        if (strcmpi (get (child, 'HandleVisibility'), 'off') == 1)
            return;
        end
        panel = child;
        if (plotbrowser.hasProxyAlready (java(handle(panel))))
            return;
        end
        plotbrowser.addUIPanelProxy (java(handle(panel)), java(handle(parent)));
        updatePropertiesForObject (handle(panel));

        createListener (panel, 'ObjectChildAdded', {@figChildAddedCallback}, 'ObjectChildAddedLsnr',0);
        createListener (panel, 'ObjectChildRemoved', {@figChildRemovedCallback}, 'ObjectChildRemovedLsnr',1);

        createPropertyListenersForObject (handle(panel));
        % go depth-first through its children and see if it has any nested
        % uipanels or axes
        buildUpModel (panel);
    end
    end
    %-- Checked for axes via command line:  OK
    %-- Checked for axes via figure palette:  OK
    %-- Checked for uipanels:  OK

    %-------------------------------
    function figChildRemovedCallback (fig, childEventData)  %#ok<INUSL>
        
    child = childEventData.Child;
    
    if (max (strcmpi (class(child), {'axes', 'uipanel'})) == 1)
        plotbrowser.removeProxy (java(handle(child)));
        
        removeListeners (child);
        % Make sure all the events are processed before proceeding or 
        % a race condition can occur when changing the plot type from the
        % Property Editor (g392677)
        drawnow;
    end
    end
    
%-------------------------------
    function ret = localFindFilter(h)
    % Return false if the input object is the child of a high level
    % aggregate plotting object.
    
       filterClassIgnoreChildren = {'specgraph.barseries',...
            'specgraph.areaseries',...
            'specgraph.contourgroup',...
            'specgraph.errorbarseries',....
            'specgraph.quivergroup',...
            'specgraph.scattergroup',...
            'specgraph.stairseries',...
            'specgraph.stemseries'};

        parent = handle(get(h,'parent'));

        if any(strcmp(class(parent),filterClassIgnoreChildren))
            ret = false;
        else
            ret = true;
        end
    end

%-------------------------------
    function figPastePlotDoneCallback (fig, eventData) %#ok<DEFNU,INUSL>
        
        %ToDo: 
        % When undoing a "cut" of an axes with plots, the value of 
        % hObjArray may by just an axes handle. We need to get all
        % visible children handles for the listeners. Instead of doing
        % a findobj, consider a recursive strategy so that we can still
        % use the fast vectorized registration mechanism.
        hObjArray = eventData.ObjectsCreated;
        
        % Filter out children of high level plotting objects
        hObjArray = handle(findobj(double(hObjArray),'-function',@localFindFilter));
        
        if ~isempty(hObjArray)     
             % Vectorize large input arrays, see g192168.
            if doFastRegister(hObjArray)
                registerListenersForObjectArray(hObjArray);
            else
                for n = 1:length(hObjArray)
                    registerListenersForObject(hObjArray(n));
                end
            end
        end
    end
    %-- Checked for plot command:   OK
    %-- Checked for paste:  OK

    %-------------------------------
    function [bool] = doFastRegister(hObjArray)
    % Return true if the input array of objects are all of
    % the same leaf class, have the same parent, and are not axes.
    
        bool = true;
        classPrev = '';
        hParent = []; 
        
        for n = 1:length(hObjArray)
            classNew = class(hObjArray(n)); 
            hParentNew = get(hObjArray(n),'Parent');
            
            % First time through
            if n<=1 
                hParent = hParentNew;
                if strcmpi(classNew,'axes')
                    bool = false;
                    break;
                end
                
            % Break out if we fail criteria    
            elseif n>1 && (~strcmp(classNew,classPrev) || ~isequal(hParent,hParentNew))
                bool = false;
                break;
            end
            classPrev = classNew;
        end

    end

    %-------------------------------
    function registerListenersForObjectArray(hObjArray)
    % Register listeners for the input object array
        
        h = hObjArray(1);

        % Get the list of property objects
        propNames = getInterestPropertyNamesForObject(h);
        props = handle([]);
        for n = 1:length(propNames)
            props(n) = findprop(handle(h),propNames{n});
        end
        createPropertyListenersForObjectArray(hObjArray,props);

        % Loop through array and handle special case listeners defined
        % at the top of this this file.
        for m = 1:length(hObjArray)
            for n = 1:length(propSpecialListeners)
                if isa(hObjArray(m),propSpecialListeners(n).Class)
                    createListener(hObjArray(m),...
                        propSpecialListeners(n).Event,...
                        propSpecialListeners(n).Callback,...
                        [propSpecialListeners(n).Event,'lsnr'],...
                        propSpecialListeners(n).RecursionLimit);
                    break;
                end
            end
        end

        % Populate a java array before passing to plot tools
        len = length(hObjArray);
        ja = javaArray('com.mathworks.page.plottool.plotbrowser.PlotBrowserEntry',len);
        
        % Add objects to the plot tools object browser
        for n = 1:len
            hAxesChild = handle(hObjArray(n));
            hParent = handle(get(hAxesChild,'Parent'));
            nearestClass = getNearestKnownParentClass(hAxesChild);
            ja(n) = com.mathworks.page.plottool.plotbrowser.PlotBrowserEntry(hAxesChild,hParent,nearestClass);
        end
        
        plotbrowser.addSeriesProxyArray_MatlabThread(ja);
        
        % ToDo: Improve performance, find a way to remove this looping
        for n = 1:len
            hAxesChild = handle(hObjArray(n));
            updatePropertiesForObject(hAxesChild);
        end
        
    end

    %-------------------------------
    function registerListenersForObject(obj)
    % Register listeners for the input object
    
        if strcmpi(class(obj),'axes')
            return;
            % ...because we're only interested in axes children!
            % If it's an axes, a figChildAdded has already fired.
        end
        axesChild = obj;
        if (plotbrowser.hasProxyAlready (java(handle(axesChild))))
            return;
        end
        createPropertyListenersForObject (axesChild);

        % Handle special case listeners
        for n = 1:length(propSpecialListeners)
            if isa(axesChild,propSpecialListeners(n).Class)
                createListener(axesChild,...
                    propSpecialListeners(n).Event,...
                    propSpecialListeners(n).Callback,...
                    [propSpecialListeners(n).Event,'lsnr'],...
                    propSpecialListeners(n).RecursionLimit);
                break;
            end
        end

        plotbrowser.addSeriesProxy_MatlabThread(...
            java(handle(axesChild)), ...
            java(handle(get(axesChild,'parent'))), ...
            getNearestKnownParentClass(axesChild));
        updatePropertiesForObject (handle(axesChild));

    end

    %-------------------------------
    function axesChildAddedCallback (axes, childEventData)
    axesChild = childEventData.Child;
    if (strcmpi (class(axesChild), 'text') == 1)
        % Do this "on spec."  This may be a title, and maybe not, but we
        % can't know at this point.  We'll find out in the callback...
        createPropertyListener (axesChild, 'String', {@titlePropertySetCallback, axes});
        return;
    end

        %AII fixes g455157 
        %true means images can be added (that is treat them as legendable)
        %legendable = meaningful to show it to a user
        if strcmpi(get(axesChild,'type'),'image')                
            if hasbehavior(axesChild,'legend')
                isleg = ~isempty(getLegendableImages(axesChild));
            else
                isleg = false;
            end
        else
            isleg = graph2dhelper('islegendable',axesChild);
        end
        if ~isleg
             return;
        end
  
        if (plotbrowser.hasProxyAlready (java(handle(axesChild))))
            return;
        end
        createPropertyListenersForObject (axesChild);
        plotbrowser.addSeriesProxy_MatlabThread ...
            (java(handle(axesChild)), ...
            java(handle(get(axesChild,'parent'))), ...
            getNearestKnownParentClass(axesChild));
        updatePropertiesForObject (handle(axesChild));
    
    end
    %-- Checked for image:  OK
    %-- Checked for line:  OK
    %-- Checked for patch:  OK
    %-- Checked for functionline:  OK
    %-- Checked for constantlineseries:  OK
    %-- Checked for ordinary lineseries (negative test):  OK

    %-------------------------------
    function axesChildRemovedCallback (axes,childEventData)
        if isempty(ancestor(axes,'figure'))
            return
        end
        child = childEventData.Child;
        if (strcmpi (class(child), 'text') == 1)
            % if it's the axes title, deal with it
            if (handle(get(axes, 'Title')) == child)
                plotbrowser.updateAxesTitle (java(handle(axes)), '');
                return;
            end
        else
            plotbrowser.removeProxy (java(handle(child)));
            removeListeners (child);
            % Make sure all the events are processed before proceeding or 
            % a race condition can occur when changing the plot type from the
            % Property Editor (g392677)
            drawnow;

        end

    
    end
    %-- Checked for lineseries:  OK
    %-- Checked for patch:  OK
    %-- Checked for text (negative test):  OK
    %-- Checked for arrow (negative test):  OK

    %-------------------------------
    function propertySetCallback (~, propertyEventData) 
        
    whichProperty = propertyEventData.Source.Name;
    affectedObj = propertyEventData.AffectedObject;
    plotbrowser.updateProperty (java(handle(affectedObj)), whichProperty);
    if (strcmpi (whichProperty, 'Title') == 1) && isa (affectedObj, 'hg.axes')
        axesTitle = get (affectedObj, 'Title');  % PostSet event, so we can do this
        titleString = get (axesTitle, 'String');
        plotbrowser.updateAxesTitle (java(handle(affectedObj)), titleString);
        createPropertyListener (axesTitle, 'String', {@titlePropertySetCallback, affectedObj});
    end
    end
    %-- Checked for axes visible/invisible:  OK
    %-- Checked for title reference:  (how can I test this?)
    %-- Checked for lineseries visible/invisible:  OK 
    %-- Checked for lineseries color:  OK

    %-------------------------------
    function barColorSetCallback (barseries, colorEventData) %#ok<INUSD>
       plotbrowser.updateProperty (java(handle(barseries)), 'FaceColor');
    end
    %-- Checked for barseries:  OK
    %-- Checked for areaseries:  OK
    %-- Checked for lineseries (negative test):  OK

    %-------------------------------
    function titlePropertySetCallback (obj, propertyEventData, axes) %#ok
    val = propertyEventData.NewValue;
    % When this callback was added, we didn't know if this text was really
    % the axes title.  But now we can find out.  If it is, do the update.
    if get(propertyEventData,'AffectedObject') == handle(get(axes,'Title'))
        plotbrowser.updateAxesTitle (java(handle(axes)), val);
    end
    end
    %-- Checked for title string:  OK

    %-------------------------------
    function objDestroyedCallback (obj, eventData)  %#ok<INUSD>
    removeListeners (obj);   
    end
    
    

    % Here's a bunch of helper functions.

    %-------------------------------
    function createListener (obj, ev, callback, uniqueName, recursionLimit)
    % Creates the listener and stores it in the object for safekeeping.


    if isempty(obj) || ~ishandle(obj)
       return;
    end
    lsnr = handle.listener (obj, ev, callback);

        
    % Set the recursion limit if present
    if( ~isempty(recursionLimit) )
        lsnr.RecursionLimit = recursionLimit;
    end

    % This guarantees that the event handlers will not pass out of scope
    % and be garbage-collected:
    if ~isprop (handle(obj), 'PlotBrowserListeners')            
        p = schema.prop (handle(obj), 'PlotBrowserListeners', 'MATLAB array');
        p.AccessFlags.Serialize = 'off';
        set (p, 'Visible', 'off');
        set (handle(obj), 'PlotBrowserListeners', struct);
    end
    
    str = get(obj, 'PlotBrowserListeners');
    str.(uniqueName) = lsnr;
    set(obj, 'PlotBrowserListeners', str);  
    
    end

    %-------------------------------
    function createPropertyListener (obj, propName, callback)
    % Very similar to createListener, but specialized for property post-set
    % listeners.
    if isempty(obj) || ~ishandle(obj)
        return;
    end

    lsnr = handle.listener (obj, findprop(handle(obj), propName), 'PropertyPostSet', callback);
    uniqueName = strcat (propName, 'Lsnr');
    if ~isprop (handle(obj), 'PlotBrowserListeners')
        p = schema.prop (handle(obj), 'PlotBrowserListeners', 'MATLAB array');
        p.AccessFlags.Serialize = 'off';
        set (p, 'Visible', 'off');
        set (handle(obj), 'PlotBrowserListeners', struct);
    end
    str = get(obj, 'PlotBrowserListeners');
    str.(uniqueName) = lsnr;
    set(obj, 'PlotBrowserListeners', str);
    end

    %-------------------------------
    function createPropertyListenersForObject(obj)

        [propNames] = getInterestPropertyNamesForObject(obj);
        for i = 1:length(propNames)
            if isprop (handle(obj), propNames{i})
                createPropertyListener (obj, propNames{i}, {@propertySetCallback});
            end
        end
    end

    %-------------------------------
    function createPropertyListenersForObjectArray(hObjArray,hPropArray)
        try

            lsnr = handle.listener (hObjArray, hPropArray, ...
                    'PropertyPostSet', {@propertySetCallback});
            uniqueName = strcat ('setupplotbrowserlist', 'Lsnr');
            obj = hObjArray(1);
            if ~isprop (handle(obj), 'PlotBrowserListeners')
                p = schema.prop (handle(obj), 'PlotBrowserListeners', 'MATLAB array');
                p.AccessFlags.Serialize = 'off';
                set (p, 'Visible', 'off');
                set (handle(obj), 'PlotBrowserListeners', struct);
            end
            str = get(obj, 'PlotBrowserListeners');
            str.(uniqueName) = lsnr;
            set(obj, 'PlotBrowserListeners', str);
        catch ex
            disp(ex.message)
        end

    end

    %-------------------------------
    function [str] = getInterestPropertyNamesForObject(obj)
        str = [];

        % Uses the allPropNames table to create a set of property listeners for
        % this object.  What properties get listened to depends on the type of
        % object.  The PlotBrowser does not need to know about every change,
        % only a few presentation-related changes.
        if isempty(obj) || ~ishandle(obj)
            return;
        end
        propNames = {'Visible', 'HandleVisibility'};
        % These two properties will be listened to for any HG obj, so they're
        % good default propNames to start with (in case we don't find this obj
        % in the allPropNames table).
        objType = class(obj);
        for i = 1:length(allPropNames)
            entry = allPropNames{i};
            if (strcmpi (objType, entry{1}) == 1)
                propNames = entry{2};
                break;
            end
        end
        str = propNames;
    end

    %-------------------------------
    function updatePropertiesForObject (obj)
    % Called whenever an HG object is detected and added to the PlotBrowser
    % tree model.  It collects all the relevant property values from the HG
    % object and initializes the new proxy object (on the Java side) with 
    % those values.
    if isempty(obj) || ~ishandle(obj)
        return;
    end
    objType = class(obj);
    propNames = [];
    for i = 1:length(allPropNames)
        entry = allPropNames{i};
        if (strcmpi (objType, entry{1}) == 1)
            propNames = entry{2};
            break;
        end
    end
    

    for i = 1:length(propNames)
        plotbrowser.updateProperty (java(handle(obj)), propNames(i));
    end
    if strcmpi(objType, 'axes')
        title = get (obj, 'Title');
        str = get (title, 'String');
        plotbrowser.updateAxesTitle (java(handle(obj)), str);
    end
    end

    %% --------------------------------------------
    function objType = getNearestKnownParentClass (obj)
      
        knownClasses = {'figure', 'axes', 'graph2d.lineseries', ...
                            'specgraph.barseries', 'specgraph.stemseries', ...
                            'specgraph.stairseries', ...
                            'specgraph.areaseries', 'specgraph.errorbarseries', ...
                            'specgraph.scattergroup', 'specgraph.contourgroup', ...
                            'specgraph.quivergroup', 'graph3d.surfaceplot', ...
                            'image', 'uipanel', 'uicontrol,' ...
                            'scribe.line', 'scribe.arrow', 'scribe.doublearrow', ...
                            'scribe.textarrow', 'scribe.textbox', 'scribe.scriberect', ...
                            'scribe.scribeellipse', 'scribe.legend', 'scribe.colorbar', ...
                            'line', 'text', 'rectangle', 'patch', 'surface'};

        objType = class(handle(obj));
        for i = 1:length(knownClasses)
            if isa (handle(obj), knownClasses{i})
                objType = knownClasses{i};
                return;
            end
        end
    end

    %-------------------------------
    function removeListeners (obj)
   
    if isprop (handle(obj), 'PlotBrowserListeners')
        set (handle(obj), 'PlotBrowserListeners', []);
    end
    end


    % Rebuild the proxies for an axes. This function is called on creation
    % of the Plot Browser, when the user adds an axes to a figure, or if
    % the ChildContainer changes (e.g if the axes is converted 2d <-> 3d)
    function refreshAxes(axes)
        
           allChildren = graph2dhelper ('get_legendable_children', axes);
           allChildren = [allChildren,getLegendableImages(axes)];
            
            for j = 1:length(allChildren)
                axesChild = allChildren(j);
                if (plotbrowser.hasProxyAlready (java(handle(axesChild))))
                    continue;
                end
                
                createPropertyListenersForObject (handle(axesChild));
                plotbrowser.addSeriesProxy_MatlabThread ...
                    (java(handle(axesChild)), ...
                     java(handle(axes)), ...
                     getNearestKnownParentClass(axesChild));
                updatePropertiesForObject (handle(axesChild));
            end
    end
end
