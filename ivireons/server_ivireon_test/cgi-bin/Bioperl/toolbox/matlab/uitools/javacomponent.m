function [hcomponent, hcontainer] = javacomponent(component, position, parent, callback)
% This function is undocumented and will change in a future release

% JAVACOMPONENT Create a Java Swing Component and put it in a figure
%
% JAVACOMPONENT(COMPONENTNAME) creates the Java component specified by the
% string COMPONENTNAME and places it in the current figure or creates a new
% figure if one is not available. The default position is [20 20 60 20].
% NOTE: This is a thread safe way to create and embed a java component in a
% figure window. If COMPONENTNAME is a cellarray, the 1st input must be a
% string with the component name and subsequent entries can be constructor
% input arguments. For more thread safe functions to create and modify java
% components, see javaObjectEDT, javaMethodEDT.
%
% JAVACOMPONENT(..., POSITION, PARENT) places the Java component in the
% specified PARENT at position POSITION. PARENT can be a Figure, a Uipanel,
% or a Uitoolbar. POSITION is in pixel units with the format [left, bottom,
% width, height]. Note that POSITION is ignored if PARENT is a Uitoolbar.
%
% JAVACOMPONENT(..., CONSTRAINT, PARENT) places the Java component next to
% the figure's drawing area using CONSTRAINT. CONSTRAINT can be NORTH,
% SOUTH, EAST, OR WEST - following Java AWT's BorderLayout rules. The
% handle to the Java component is returned on success, empty is returned on
% error. If the parent is a uipanel, the component is placed in the parent
% figure of the uipanel. If parent is a uitoolbar, CONSTRAINT is ignored
% and the component is placed last in the child list for the given toolbar.
%
% [HCOMPONENT, HCONTAINER] = JAVACOMPONENT(...)
% returns the handle to the Java component in HCOMPONENT and its HG
% container in HCONTAINER. HCONTAINER is only returned when pixel
% positioning is used. It should be used to change the units, position, and
% visibility of the Java component after it is added to the figure.
%
%   Examples:
%
%   f = figure;
%   b = javacomponent({'javax.swing.JButton','Hello'}, [], f,  ...
%           {'ActionPerformed','disp Hi'});
%
%   f = figure('WindowStyle', 'docked');
%   b1 = javacomponent('javax.swing.JButton', [], f, ...
%           {'ActionPerformed','disp Hi'});
%   b1.setLabel('Hello')
%
%   f = figure;
%   [comp, container] = javacomponent('javax.swing.JSpinner');
%   set(container,'Position', [100, 100, 100, 40]);
%   set(container,'Units', 'normalized');
%
%   f = figure;
%   p = uipanel('Position', [0 0 .2 1]);
%   ppos = getpixelposition(p);
%   [tree treecontainer] = javacomponent('javax.swing.JTree', ...
%                             [0 0 ppos(3) ppos(4)], p);
%
%   f = figure('WindowStyle', 'docked');
%   % Note use of constructor args in 1st input.
%   table = javacomponent({'javax.swing.JTable', 3, 10}, ...
%              java.awt.BorderLayout.SOUTH, f);
%
%   f = figure;
%   tb = uitoolbar(f);
%   % Note: Position input is ignored.
%   b2 = javacomponent('javax.swing.JButton', [], tb, ...
%                 {'ActionPerformed','disp Hi'});
%   b2.setLabel('Hi again!')
%
% See also USEJAVACOMPONENT, javaObjectEDT, javaMethodEDT

% Deprecated input.
%
% JAVACOMPONENT(HCOMPONENT) places the Java component HCOMPONENT in the
% current figure or creates a new figure if one is not available. The
% default position is [20 20 60 20]. HCOMPONENT is tagged for autodelegation
% to the EDT.

% Copyright 1984-2010 The MathWorks, Inc.
% $Revision: 1.1.6.38.2.1 $ $Date: 2010/06/21 18:00:25 $

if (usejavacomponent == 0)
    err.message = 'JAVACOMPONENT is not supported on this platform';
    err.identifier = 'MATLAB:javacomponent:FeatureNotSupported';
    error(err);
end

if ~isempty(nargchk(1,4,nargin))  %#ok
    error('MATLAB:javacomponent',usage);
end

if nargin < 4
    callback = '';
else
    if ~iscell(callback)
        error('MATLAB:javacomponent',usage);
    end
end

if nargin < 3
    parent = gcf;
end

if nargin < 2
    position = [20 20 60 20];
end

parentIsFigure = false;
hParent = handle(parent);
% g500548 - changed to use ishghandle.
if ( ishghandle(hParent, 'figure') || ...
        ishghandle(hParent, 'uicontainer') || ...
        ishghandle(hParent, 'uiflowcontainer') || ...
        ishghandle(hParent, 'uigridcontainer'))
    parentIsFigure = true;
    
    peer = getJavaFrame(ancestor(parent,'figure'));
elseif ishghandle(hParent, 'uitoolbar')
    peer = get(parent,'JavaContainer');
    if isempty(peer)
        drawnow;
        peer = get(parent,'JavaContainer');
    end
elseif (ishghandle(hParent, 'uisplittool') || ...
        ishghandle(hParent, 'uitogglesplittool'))
    parPeer = get(get(hParent,'Parent'),'JavaContainer');
    if isempty(parPeer)
        drawnow;
    end
    peer = get(parent,'JavaContainer');
else
    error('MATLAB:javacomponent:InvalidParentHandle', 'Invalid parent handle\n%s', usage)
end

if isempty(peer)
    error('MATLAB:javacomponent:JavaFigsNotEnabled', 'Java figures are not enabled')
end

hUicontainer = [];
hgp = [];
returnContainer = 1;

if ischar(component)
    % create from class name
    component = javaObjectEDT(component);
elseif iscell(component)
    % create from class name and input args
    component = javaObjectEDT(component{:});
elseif ~isa(component,'com.mathworks.hg.peer.FigureChild')
    % tag existing object for auto-delegation - unless it is a FigureChild
    javaObjectEDT(component);
end

% Promote the component to a handle object first. It seems once a java
% object is cast to a handle, you cannot get another handle with
% 'callbackproperties'.
if ~isjava(component)
    component = java(component);
end
hcomponent  = handle(component,'callbackProperties');

if nargin == 1
    hgp = handle(peer.addchild(component));
    % parent must be a figure, we default to gcf upstairs
    createPanel;
    hgp.setUIContainer(double(hUicontainer));
else
    if parentIsFigure
        if isnumeric(position)
            if isempty(position)
                position = [20 20 60 20];
            end
            % numeric position is not set here, rely on the uicontainer
            % listeners below.
            hgp = handle(peer.addchild(component));
            createPanel;
            hgp.setUIContainer(double(hUicontainer));
        elseif ...
                isequal(char(position),char(java.awt.BorderLayout.NORTH)) || ...
                isequal(char(position),char(java.awt.BorderLayout.SOUTH)) || ...
                isequal(char(position),char(java.awt.BorderLayout.EAST))  || ...
                isequal(char(position),char(java.awt.BorderLayout.WEST))
            hgp = handle(peer.addchild(component, position));
            returnContainer = 0;
            createPanel;
        else
            error('MATLAB:javacomponent:InvalidPosition', 'Invalid component position\n%s', usage)
        end
    else
        % Adding component to the toolbar.
        % component position is ignored
        peer.add(component);
        hUicontainer = parent; % toolbar.
        handles = getappdata(hUicontainer, 'childhandles');
        handles = [handles, hcomponent];
        setappdata(hUicontainer, 'childhandles', handles);
    end
    
    % make sure the component is on the screen so the
    % caller can interact with it right now.
    % drawnow;
end

configureComponent;

% If asked for callbacks, add them now.
if ~isempty(callback)
    % The hg panel is the best place to store the listeners so they get
    % cleaned up asap. We can't do that if the parent is a uitoolbar so we
    % just put them on the toolbar itself.
    lsnrParent = hgp;
    if isempty(lsnrParent)
        lsnrParent = hParent;
    end
    if mod(length(callback),2)
        error('MATLAB:javacomponent',usage);
    end
    for i = 1:2:length(callback)
        lsnrs = getappdata(lsnrParent,'JavaComponentListeners');
        l = javalistener(component, callback{i}, callback{i+1});
        setappdata(lsnrParent,'JavaComponentListeners',[l lsnrs]);
    end
end

if (returnContainer == 1)
    hcontainer = hUicontainer;
else
    hcontainer = [];
end

    function createPanel
        % add delete listener
        hUicontainer = hgjavacomponent('Parent',parent,'Units', 'Pixels');
        
        set(hUicontainer, 'UserData', char(component.getClass.getName)); % For findobj queries.
        if isa(java(hgp), 'com.mathworks.hg.peer.FigureChild')
            set(hUicontainer, 'FigureChild', hgp);
        end
        if isa(java(hcomponent), 'javax.swing.JComponent')
            % force component to be opaque if it's a JComponent. This prevents
            % lightweight component from showing the figure background (which
            % may never get a paint event)
            hcomponent.setOpaque(true);
        end
        set(hUicontainer, 'JavaPeer', hcomponent);
        
        if (returnContainer == 1)
            % add resize listener to parent (parent must be a figure or this dies quietly)
            % this is for normalized units
            addlistener(hUicontainer, 'PixelBounds', 'PostSet', @handleResize);
            
            % add visible listener
            addlistener(hUicontainer, 'Visible', 'PostSet', @handleVisible);
            
            %Parent was set before we get here. Hence we need to explicitly
            %walk up and attach listeners. For subsequent parent changes,
            %the parent property postset listener callback will take care of setting
            %up the hierarchy listeners to listen for position and visible changes
            createHierarchyListeners(hUicontainer, @handleResize, @handleVisible);
            
            
            
            
            % add parent listener
            addlistener(hUicontainer, 'Parent', 'PreSet', @handlePreParent);
            
            % add parent listener
            addlistener(hUicontainer, 'Parent', 'PostSet', @(o,e) handlePostParent(o,e,@handleResize, @handleVisible));
            
            % force though 1st resize event
            set(hUicontainer,'Position', position);
        else
            % For the BorderLayout components, we dont really want the
            % hUicontainer to show. But, it provides a nice place for cleanup.
            set(hUicontainer,'Visible', 'off', 'Handlevisibility', 'off');
            % Set position out of the figure to work around a current bug
            % due to which invisible uicontainers show up when renderer is
            % OpenGL (G.
            set(hUicontainer, 'Position', [1 1 0.01 0.01]);
        end
        
        if isa(component,'com.mathworks.hg.peer.FigureChild')
            component.setUIContainer(double(hUicontainer));
        end
        
        function handleResize(obj, evd) %#ok - mlint
            hgp.setPixelPosition(getpixelposition(hUicontainer, true));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % g482174 - Bandage solution to support hierarchy visibility changes
        % We will look for any invisible parent container to see if we can
        % show the javacomponent or not.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function handleVisible(obj, evd) %#ok - mlint
            source = evd.AffectedObject;
            if ishghandle(source,'hgjavacomponent')
                hgp.setVisible(strcmp(get(source,'Visible'),'on'));
            else
                if (strcmp(get(source,'Visible'),'off'))
                    setInternalVisible(hUicontainer, component, false);
                else
                    stParent = get(hUicontainer,'Parent');
                    hgjcompVisible = strcmp(get(hUicontainer,'Visible'),'on');
                    visible = hgjcompVisible && strcmp(get(stParent,'Visible'),'on');
                    while (~ishghandle(stParent,'root') && visible)
                        stParent = get(stParent,'Parent');
                        visible = visible && strcmp(get(stParent,'Visible'),'on');
                    end
                    setInternalVisible(hUicontainer, component, visible);
                end
            end
            drawnow update;
        end
        
        
        
        
        
        
        function handlePreParent(obj, evd) %#ok - mlint
            oldfig = ancestor(hUicontainer, 'figure');
            removecomponent = true;
            % NewValue field is absent in MCOS and hence we need to do the
            % following safely.
            if ~isempty(findprop(evd,'NewValue'))
                newfig = ancestor(evd.NewValue, 'figure');
                removecomponent = ~isempty(newfig) && ~isequal(oldfig, newfig);
            end
            %We are losing on this optimization(event may not have NewValue). We always
            %remove and add upon reparenting. We do not have the context of
            %the new parent in the preset to do a compare to see if we are
            %being parented to the same parent again. We hope that this is
            %not done often.
            if  (removecomponent)
                peer = getJavaFrame(oldfig);
                peer.remove(component);
            end
        end
        
        function handlePostParent(obj, evd, resizeCbk, visibleCbk) %#ok - mlint
            createHierarchyListeners(hUicontainer, resizeCbk, visibleCbk);
            oldfig = ancestor(hUicontainer, 'figure');
            newfig = ancestor(evd.AffectedObject, 'figure');
            if ~isempty(newfig) && ~isequal(oldfig, newfig)
                peer = getJavaFrame(newfig);
                hgp= handle(peer.addchild(component));
                if isa(java(hgp), 'com.mathworks.hg.peer.FigureChild')
                    % used by the uicontainer C-code
                    setappdata(hUicontainer, 'FigureChild', java(hgp));
                end
                parent = newfig;
            end
            hgp.setPixelPosition(getpixelposition(hUicontainer, true));
        end
    end

    function configureComponent
        set(hUicontainer,'DeleteFcn', {@containerDelete, hcomponent});
        %         addlistener(java(hcomponent), 'ObjectBeingDestroyed', @(o,e)componentDelete(o,e,hUicontainer, parentIsFigure));
        temp = handle.listener(hcomponent, 'ObjectBeingDestroyed', @(o,e)componentDelete(o,e,hUicontainer, parentIsFigure));
        save__listener__(hcomponent,temp);
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% g637916 - Visibility of the hgjavacomponent is posing issues due to the
% fact that the state is being used to control visibility and hence when
% the parent's are turned visible off, we need an alternate api to make it
% go away from the screen.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setInternalVisible(hUicontainer, component ,vis)
[cleaner lastWarnMsg lastWarnId] = doSetup;
setVisibility(handle(hUicontainer),vis);
setVisible(component, vis);
doCleanup(cleaner, lastWarnMsg, lastWarnId);
end

function [cleaner lastWarnMsg lastWarnId] = doSetup
[ lastWarnMsg lastWarnId ] = lastwarn;
usagewarning =warning('off','MATLAB:javacomponent');
cleaner = onCleanup(@() warning(usagewarning));
end

function doCleanup(cleaner , lastWarnMsg, lastWarnId)
delete(cleaner);
lastwarn(lastWarnMsg, lastWarnId);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function containerDelete(obj, evd, hc) %#ok - mlint
obj = handle(obj);
if ishghandle(handle(obj), 'uitoolbar') || ...
        ishghandle(handle(obj),'uisplittool') || ...
        ishghandle(handle(obj),'uitogglesplittool');
    childHandles = getappdata(obj, 'childhandles');
    delete(childHandles(ishandle(childHandles)));
else
    if ishandle(hc)
        delete(hc);
    end
end
end

function componentDelete(obj, evd, hUicontainer, parentIsFigure) %#ok - mlint
if (parentIsFigure)
    % This java component is always deleted before hUicontainer. It is
    % ensured by calling component deletion in function containerDelete.
    % hUicontainer becomes invalid when delete(hUicontainer) below is run.
    parent = ancestor(hUicontainer,'figure');
    
    peer = getJavaFrame(parent);
    
    if any(ishandle(obj))
        removeobj = java(obj);
        if ~isempty(get(hUicontainer,'FigureChild'))
            removeobj  = get(hUicontainer,'FigureChild');
        end
        peer.remove(removeobj);
    end
    
    % delete container if it exists
    if any(ishghandle(hUicontainer))
        delete(hUicontainer);
    end
else
    parent = hUicontainer; % toolbar or split tool
    if ~ishandle(parent) || ~ishandle(obj)
        % The toolbar parent or the component has been deleted. Bail out.
        % Toolbar clears all javacomponents after itself.
        return;
    end
    
    % For uisplittool and uitogglesplittool objects
    % The parent may have done this deletion for us
    % already.
    hPar = get(parent,'Parent');
    if ishghandle(handle(hPar),'uitoolbar')
        parPeer = get(hPar,'JavaContainer');
        if isempty(parPeer)
            return;
        end
    end
    
    peer = get(parent, 'JavaContainer');
    if ~isempty(peer)
        peer.remove(java(obj));
    end
end
end

function hdl=javalistener(jobj, eventName, response)
try
    jobj = java(jobj);
catch ex  %#ok
end

% make sure we have a Java objects
if ~ishandle(jobj) || ~isjava(jobj)
    error('MATLAB:javacomponent:invalidinput','First input must be a java object')
end

hSrc = handle(jobj,'callbackproperties');
allfields = sortrows(fields(set(hSrc)));
alltypes = cell(length(allfields),1);
j = 1;
for i = 1:length(allfields)
    fn = allfields{i};
    if ~isempty(findstr('Callback',fn))
        fn = strrep(fn,'Callback','');
        alltypes{j} = fn;
        j = j + 1;
    end
end
alltypes = alltypes(~cellfun('isempty',alltypes));

if nargin == 1
    % show or return the possible events
    if nargout
        hdl = alltypes;
    else
        disp(alltypes)
    end
    return;
end

% validate event name
valid = any(cellfun(@(x) isequal(x,eventName), alltypes));

if ~valid
    error('MATLAB:javacomponent:invalidevent', ...
        'Callback name unrecognized for %s. \nValid callbacks are:\n %s', ...
        class(jobj),  ...
        char(cellfun(@(x) sprintf('\t%s',x), alltypes,'UniformOutput',false))')
end

hdl = handle.listener(handle(jobj), eventName, ...
    @(o,e) cbBridge(o,e,response));
    function cbBridge(o,e,response)
        hgfeval(response, java(o), e.JavaEvent)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Since we setup resize listeners on the parents of hgjavacomponent, we
% must make sure they get deleted when the hgjavacomponent gets deleted.
% Otherwise, if we delete the hgjavacomponent and a figure resize comes
% in later, that would trigger handleResize and we would error out.
% g579710
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function createHierarchyListeners(hUicontainer, resizeCbk, visCbk)
deleteExistingHierarchyListeners(hUicontainer, []);
hUicontainer = handle(hUicontainer);
parent = get(hUicontainer,'Parent');
% Walk up instance hierarchy and put a listener on all the
% containers. We don't need a listener on the figure.
while ~ishghandle(parent,'figure')
    %Set up all the resize listeners
    createResizeListener(parent, hUicontainer, resizeCbk);
    %Set up all the visible listeners
    createVisibleListener(parent, hUicontainer, visCbk);
    %Keep walking up
    parent = get(parent,'Parent');
end

% Special case figure
createVisibleListener(ancestor(hUicontainer,'figure'), hUicontainer, visCbk);

% When the hgjavacomponent goes away, clean all listeners
addlistener(hUicontainer, 'ObjectBeingDestroyed', @(o,e) deleteExistingHierarchyListeners(o,e));
end

function deleteExistingHierarchyListeners(src,~)
hUicontainer = handle(src);
%Delete all the resize listeners
if isListenerData(hUicontainer, 'ResizeListeners')
    appdata = getListenerData(hUicontainer, 'ResizeListeners');
    cellfun(@(x) delete(x), appdata, 'UniformOutput',false);
    setListenerData(hUicontainer, 'ResizeListeners',{});
end

%Delete all the visibility listeners
if isListenerData(hUicontainer, 'VisiblilityListeners')
    appdata = getListenerData(hUicontainer, 'VisiblilityListeners');
    cellfun(@(x) delete(x), appdata, 'UniformOutput',false);
    setListenerData(hUicontainer, 'VisiblilityListeners',{});
end

end


function createResizeListener(object, hUicontainer, resizeCbk)
%Attach resize listeners
pixBoundListnr = addlistener(object, 'PixelBounds', 'PostSet', resizeCbk);
if (~isListenerData(hUicontainer, 'ResizeListeners'))
    setListenerData(hUicontainer, 'ResizeListeners',{});
end
pixBoundAppdata = getListenerData(hUicontainer, 'ResizeListeners');
pixBoundAppdata{end+1} = pixBoundListnr; %#ok<AGROW>
setListenerData(hUicontainer, 'ResizeListeners', pixBoundAppdata);
end

function createVisibleListener(object, hUicontainer, visCbk)
%Attach visibility listeners
visContainerListnr = addlistener(object, 'Visible','PostSet', visCbk);
if (~isListenerData(hUicontainer, 'VisiblilityListeners'))
    setListenerData(hUicontainer, 'VisiblilityListeners',{});
end
visibilityAppdata = getListenerData(hUicontainer, 'VisiblilityListeners');
visibilityAppdata{end+1} = visContainerListnr; %#ok<AGROW>
setListenerData(hUicontainer, 'VisiblilityListeners', visibilityAppdata);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function str=usage
str = [sprintf('\n') ...
    'WARNING: This feature is not supported in MATLAB and the API and ' sprintf('\n') ...
    'functionality may change in a future release. ' sprintf('\n') ...
    ];
str = [str sprintf('\n') ...
    'usage: javacomponent(javaClassName, position, parent, callback) ' sprintf('\n') ...
    '- position can be empty, [left bottom width height] in pixels ' sprintf('\n') ...
    '  or the string North, South, East, or West.' sprintf('\n') ...
    '- parent can be a figure or a uitoolbar handle.' sprintf('\n') ...
    '- callback can be empty or a cell array of JavaEvents and their handlers.' ...
    ];
end

function javaFrame = getJavaFrame(f)
% store the last warning thrown
[ lastWarnMsg lastWarnId ] = lastwarn;

% disable the warning when using the 'JavaFrame' property
% this is a temporary solution
oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
javaFrame = get(f,'JavaFrame');
warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

% restore the last warning thrown
lastwarn(lastWarnMsg, lastWarnId);
end
