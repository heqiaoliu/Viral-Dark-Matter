function api = iptPointerManager(figHandle, str)
%iptPointerManager Install mouse pointer manager in figure.
%   iptPointerManager(hFigure) creates a pointer manager in the specified
%   figure.
%
%   iptPointerManager(hFigure, 'disable') disables the figure's pointer
%   manager.
%
%   iptPointerManager(hFigure, 'enable') enables and updates the figure's
%   pointer manager.
%
%   If the figure already contains a pointer manager, then
%   iptPointerManager(hFigure) does not create a new one.  It has the same
%   effect as iptPointerManager(hFigure, 'enable').
%
%   Use iptPointerManager in conjunction with iptSetPointerBehavior to vary
%   the figure's mouse pointer depending on which object it is
%   over. iptSetPointerBehavior is used on a specific object to define
%   specific actions that occur when the mouse pointer moves over and then
%   leaves the object.  See the iptSetPointerBehavior documentation for more
%   information.
%
%   EXAMPLE
%   =======
%   Plot a line.  Install a pointer manager in the figure, and then give the
%   line a "pointer behavior" that changes the mouse pointer into a fleur
%   whenever the pointer is over it.
%
%       h = plot(1:10);
%       iptPointerManager(gcf);
%       enterFcn = @(hFigure, currentPoint) set(hFigure, 'Pointer', 'fleur');
%       iptSetPointerBehavior(h, enterFcn);
%
%   See also iptGetPointerBehavior, iptSetPointerBehavior.

%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/04/15 15:48:13 $

% Information hiding:
% This routine hides the specific mechanism used to install and retrieve a
% pointer manager in a figure.  It hides from the client whether or not a
% pointer manager already exists in the figure.  It even hides what a
% pointer manager exactly is.

% Assert that there is one or two input arguments.
iptchecknargin(1, 2, nargin, mfilename);

% Assert that the first input argument is a valid figure handle.
iptcheckhandle(figHandle, {'figure'}, mfilename, 'figHandle', 1);

% Check second input argument.
default_str = 'enable';
if nargin < 2
    str = default_str;
end

str = validatestring(str,...
    {'enable', 'disable'},...
    mfilename,...
    'STR',...
    2);

pointerManager = getFigurePointerManager(figHandle);

% If no pointer manager found, create one.
if isempty(pointerManager)
    pointerManager = createPointerManager(figHandle);
    setFigurePointerManager(figHandle, pointerManager);
end

if strcmp(str, 'enable')
    pointerManager.API.enable();
else
    pointerManager.API.disable();
end

if nargout > 0
    % Output argument is to facilitate unit testing.  It is undocumented.
    api = pointerManager.API;
end


end

function pointerManager = getFigurePointerManager(figHandle)
% getFigurePointerManager takes a figure handle as an input argument and
% returns the pointer manager struct, or it returns [] if there is no
% pointer manager in the figure.

% Preconditions (not checked):
%     One input argument.
%     Input argument is a valid figure handle.

% Information hiding:
%     This routine, together with setFigurePointerManager, hides the
%     specific mechanism used to save and retrieve a pointer manager in a
%     figure.

pointerManager = getappdata(figHandle, 'iptPointerManager');

% Assert that pointer manager is valid.
if ~isempty(pointerManager) && ~isValidPointerManager(pointerManager)
    error('Images:iptPointerManager:invalidPointerManagerGet', ...
        'Figure contains an invalid pointer manager.');
end
end

function setFigurePointerManager(figHandle, pointerManager)
% setFigurePointerManager(figHandle, pointerManager) stores the pointer
% manager in the specified figure.

% Preconditions (not checked):
%     Two input arguments
%     First input argument is a valid HG figure handle.
%     Second input argument is a valid pointer manager struct.

% Information hiding:
%     This routine, together with getFigurePointerManager, hides the
%     specific mechanism used to save and retrieve a pointer manager in a
%     figure.

setappdata(figHandle, 'iptPointerManager', pointerManager);

end

function p = isValidPointerManager(pointerManager)
% p = isValidPointerManager(pointerManager) returns true if its input is
% a valid pointer manager struct.  This is used to protect against the
% pointer manager struct getting corrupted, which can occur if someone
% sets the "iptPointerManager" appdata directly.

p = isscalar(pointerManager) && ...
    isstruct(pointerManager) && ...
    isfield(pointerManager, 'API') && ...
    isfield(pointerManager, 'listener');
end

function fcn = createFigurePointerRestoreFcn(figHandle)
% fcn = createFigurePointerRestoreFcn(figHandle) creates a function
% handle that sets the state of the input figure's mouse pointer to
% whatever it was when this function was called.

% Preconditions (not checked):
%     one input argument
%     input argument is a valid figure handle

figurePointer             = get(figHandle, 'Pointer');
figurePointerShapeCData   = get(figHandle, 'PointerShapeCData');
figurePointerShapeHotSpot = get(figHandle, 'PointerShapeHotSpot');
fcn = @() set(figHandle, ...
    'Pointer', figurePointer, ...
    'PointerShapeCData', figurePointerShapeCData, ...
    'PointerShapeHotSpot', figurePointerShapeHotSpot);
end

function callIfNotEmpty(fcn, varargin)
% callIfNotEmpty(fcn, varargin) calls the function handle fcn with the
% input arguments varargin{:}, unless fcn is [].  In that case, the
% function simply returns without doing anything.

if ~isempty(fcn)
    fcn(varargin{:});
end
end

function pointerManager = createPointerManager(figHandle)
% createPointerManager takes a figure handle as an input argument and
% creates a pointer manager struct.  The fields of the struct include
% api, which is the pointer manager api, and listener, which is the
% WindowButtonMotionEvent listener.

% Preconditions (not checked):
%     One input argument
%     Input argument is a valid HG figure handle.

% Information hiding:
%     Hides from the rest of the application and from clients the
%     implementation of the api and the implementation of mouse pointer
%     updating.

% Initialize outer scope of cross-function variables.
currentManagedObject = [];
figurePointerRestoreFcn = [];
isEnabled = false;
lastCurrentPoint = [0 0];
cachedEnabledState = [];

% Initialize API field of pointer manager struct with function handles
% for enable and disable.
pointerManager.API.enable = @enablePointerManager;
pointerManager.API.disable = @disablePointerManager;

% Create WindowButtonMotionEvent listener whose callback implements the
% pointer updating behavior. Save listener in the pointer manager
% struct.
callbackFcn = @(eventSource, eventData) updatePointer(double(eventSource), ...
    eventData.currentPoint);
pointerManager.listener = local_addlistener(figHandle,...
    'WindowButtonMotionEvent', ...
    callbackFcn);

% Create listener for changes to the active MATLAB figure ui mode.  If
% a mode becomes active in the current figure, then we relinquish
% control of pointer management.  Once the mode is disabled, we return
% to the previous state.
figModeManager = uigetmodemanager(figHandle);
pointerManager.modeListener = local_addlistener(figModeManager, ...
    'CurrentMode', ...
    'PreSet', @newFigureMode);

    function enablePointerManager()
        % Enables the pointer manager so that it responds to
        % WindowButtonMotionEvents.  Calls the updatePointer() function.
        %
        % Modifies cross-function variable isEnabled.
        
        isEnabled = true;
        updatePointer(figHandle, lastCurrentPoint);
    end


    function disablePointerManager
        % Disables the pointer manager so that it no longer responds to
        % WindowButtonMotionEvents.
        %
        % Modifies cross-function variable isEnabled.
        
        isEnabled = false;
    end

    function newFigureMode(~,evt)
        % Fires when the figure mode changes.  If a mode is set we cache
        % the isEnabled state and restore it when the user releases the
        % MATLAB figure mode.  NOTE: this is a preset listener.
        
        modeManager = get(evt.AffectedObject);
        noCurrentMode = isempty(modeManager.CurrentMode);
        settingFigureMode = ~isempty(evt.NewValue);
        
        if settingFigureMode
            if noCurrentMode
                % if we had no previous mode, then cache pointer mgr state
                cachedEnabledState = isEnabled;
            end
            % disable pointer mgr
            isEnabled = false;
        else
            % we are turning off the figure mode
            if ~isempty(cachedEnabledState)
                % if we had an enabled state cached, restore it
                isEnabled = cachedEnabledState;
            end
            % clear cached state
            cachedEnabledState = [];
        end
        
        
    end

    function updatePointer(hFigure, currentPoint)
        % Responds to WindowButtonMotionEvents.  Invokes pointer behavior of
        % object that pointer is over.  Updates internal state appropriately.
        %
        % Reads cross-function variable isEnabled.
        % Reads and modifies cross-function variable currentManagedObject.
        % Reads and modifies cross-function variable figurePointerRestoreFcn.
        
        % Update our last known currentPoint.  Even if the pointer manager
        % is disabled, we refresh lastCurrentPoint so that we have
        % up-to-date information when the manager is enabled.
        lastCurrentPoint = currentPoint;
        
        % If pointer manager is disabled, return early.
        if ~isEnabled
            return;
        end
        
        % Find the lowest object in the HG hierarchy starting at currentPoint that
        % has a pointer behavior.
        overMe = findLowestManagedObject(hFigure,currentPoint);
        
        % If the "over me" object is the same as the currentManagedObject,
        % then invoke the traverseFcn of the currentManagedObject and
        % return.
        if isequal(overMe, currentManagedObject)
            callIfNotEmpty(currentManagedObject.PointerBehavior.traverseFcn, ...
                hFigure, currentPoint);
            return;
        end
        
        if ~isempty(overMe.PointerBehavior)
            % If the currentManagedObject is empty, create a new
            % figurePointerRestoreFcn that will return the figure's pointer
            % to its current state; otherwise invoke the
            % currentManagedObject's exitFcn.
            if isempty(currentManagedObject)
                figurePointerRestoreFcn = createFigurePointerRestoreFcn(hFigure);
            else
                callIfNotEmpty(currentManagedObject.PointerBehavior.exitFcn, ...
                    hFigure, currentPoint);
            end
            
            % Invoke the "over me" object's enterFcn and traverseFcn.
            callIfNotEmpty(overMe.PointerBehavior.enterFcn, hFigure, currentPoint);
            callIfNotEmpty(overMe.PointerBehavior.traverseFcn, hFigure, currentPoint);
            
            % Save the "over me" object.
            currentManagedObject = overMe;
            
        else
            
            if ~isempty(currentManagedObject)
                % Invoke the currentManagedObject's exitFcn, clear the
                % currentManagedObject, and restore the figure pointer.
                callIfNotEmpty(currentManagedObject.PointerBehavior.exitFcn, ...
                    hFigure, currentPoint);
                currentManagedObject = [];
                figurePointerRestoreFcn();  %#ok - mlint warning on this line is ok.
                
            else
                % No code needed here; pointer is over unmanaged area.
            end
            
        end
        
    end
end


%-----------------------------------------------------
function result_listener = local_addlistener(varargin)
% This undocumented function may be removed in a future release.

% local_addlistener creates a listener and returns a reference to it.  It
% should be removed when hg2 is on by default


source_handle = varargin{1};
if all(ishandle(source_handle)) && isobject(source_handle)
    
    %  MCOS event listener syntaxes
    %  ============================
    %  lh = event.listener(Hobj,'EventName',@CallbackFunction)
    %  lh = event.proplistener(Hobj,Properties,'PropEvent',@CallbackFunction)
    
    source_handle = varargin{1};
    if nargin == 3
        event_type = varargin{2};
        % remove 'Event' from end of string if present
        event_loc = strfind(event_type,'Event');
        if ~isempty(event_loc)
            event_type(event_loc:event_loc+4) = [];
        end
        result_listener = event.listener(source_handle, event_type,...
            varargin{3});
    elseif nargin == 4
        property = source_handle(1).findprop(varargin{2});
        result_listener = event.proplistener(source_handle, property,...
            varargin{3:end});
    else
        eid = 'Images:iptaddlistener:invalidSyntax';
        error(eid,'Invalid number of arguments passed to iptaddlistener');
    end
    
elseif all(ishandle(source_handle)) && ~isobject(source_handle)
    
    %  handle.listener syntaxes
    %  ========================
    %  source_handle = handle(source_obj);
    %  lh = handle.listener(source_handle,...
    %     'ObjectBeingDestroyed',@callback_fcn);
    %  lh = handle.listener(source_handle, source_handle.findprop('propname'),...
    %     'PropertyPostSet', @callback_fcn);
    
    source_handle = handle(source_handle);
    if nargin == 3
        result_listener = handle.listener(source_handle,varargin{2:end});
    elseif nargin == 4
        event_type = varargin{3};
        if ~(strcmpi(event_type,'PreSet') || strcmpi(event_type,'PostSet'))
            eid = 'Images:iptaddlistener:unknownEventType';
            error(eid,'Unknown event type passed to iptaddlistener');
        end
        property = source_handle(1).findprop(varargin{2});
        event_type = sprintf('Property%s',event_type);
        result_listener = handle.listener(source_handle,property,...
            event_type,varargin{4});
    else
        eid = 'Images:iptaddlistener:invalidSyntax';
        error(eid,'Invalid number of arguments passed to iptaddlistener');
    end
    
else
    eid = 'Images:iptaddlistener:invalidObject';
    error(eid,'Invalid object passed to iptaddlistener');
    
end % local_addlistener

end