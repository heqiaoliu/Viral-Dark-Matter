function IsOwner = mouseevent(Constr,EventName,EventSrc)
%MOUSEEVENT  Processes mouse events.

%   Authors: N. Hickey
%   Revised: B. Eryilmaz, A. Stothert
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:46 $

%REVISIT
IsOwner   = 0;
hGroup    = Constr.Elements;
HostAx    = handle(hGroup.Parent);
HostFig   = HostAx.Parent;
hChildren = hGroup.Children;

switch EventName
   case 'bd'
      %Find closest edge to clicked point
      CP = get(HostAx,'CurrentPoint');
      CP(1,1) = unitconv(CP(1,1),Constr.xDisplayUnits,Constr.xUnits);
      CP(1,2) = unitconv(CP(1,2),Constr.yDisplayUnits,Constr.yUnits);
      xCoords  = Constr.xCoords;
      yCoords  = Constr.yCoords;
      Constr.SelectedEdge = localFindSelectedEdge(xCoords,yCoords,[CP(1,1), CP(1,2)]);
      % Button down event
      SelectionType = get(HostFig, 'SelectionType');
      % Constraint editor management
      switch SelectionType
         case 'open'
            % Open constraint editor
            Constr.EditDlg.show(Constr.TextEditor);
         case {'normal','extend'}
            % Interaction with constraint
            % Left click
            if Constr.EditDlg.isVisible
               % Silently retarget editor
               Constr.EditDlg.target(Constr.TextEditor);
            end

            Tags = get(hChildren,'Tag');
            idxMarker = strcmp(Tags,'ConstraintMarkers');
            idxPatch  = strcmp(Tags,'ConstraintPatch');
            idxEdge   = strcmp(Tags,'ConstraintInfeasibleEdge');
            if any(EventSrc == hChildren(idxMarker))
               % Initialize resize
               setptr(HostFig, 'closedhand');
               LocalResize(Constr, 'init');
            elseif any(EventSrc == hChildren(idxEdge))
               %Selecting edge to move
               setptr(HostFig, 'fleur');
               LocalMove('init', Constr);
            elseif any(EventSrc == hChildren(idxPatch))
               % Selecting whole constraint
               Constr.SelectedEdge = 1:size(Constr.xCoords,1);
               setptr(HostFig, 'fleur');
               LocalMove('init', Constr);
            end
         case 'alt'
            % Right click
            Constr.enableContextMenuItems(EventSrc);
      end

   case 'wbm'
      % Mouse motion.  REVISIT: upgrade to local event when available
      % Get object currently hovered
      HitObject = hittest(HostFig);
      IsOwner = any(HitObject == hChildren);
      Tags = get(hChildren,'Tag');
      idx = strcmp(Tags,'ConstraintMarkers');
      if any(HitObject == hChildren(idx))
         % Over resize markers
         setptr(HostFig, 'hand');
         Constr.EventManager.poststatus(Constr.status('hovermarker'));
      elseif IsOwner
         % Over patch or edge
         Constr.EventManager.poststatus(Constr.status('hover'));
      end
end

%-------------------- Callback functions -------------------

% %%%%%%%%%%%%%%%%%
% %%% LocalMove %%%
% %%%%%%%%%%%%%%%%%
function LocalMove(action,Constr)
% Callback for button down on constraint

persistent WBMU MoveCounter TransAction isMoving

EventMgr = Constr.EventManager;    % @eventmgr object
hGroup   = Constr.Elements;
HostAx   = handle(hGroup.Parent);
HostFig  = double(HostAx.Parent);

switch action
case 'init'
    % Initialize constraint moving algorithm. hSrc is handle of selected line
    if isempty(isMoving) || ~isMoving
       % resize is always single constr select on normal selection
       setptr(HostFig,'fleur');
       EventMgr.clearselect;
    else
       %Another key pressed while moving, stop moving
       LocalMove('finish',Constr)
       return
    end
    Constr.Selected = 'on';

    % Switch to mouse edit mode (ensures quick update with no axis limit adjustment)
    % and initialize move for selected objects in axes
    EventMgr.moveselect('init');
    MoveCounter = 0;   % Counts WBM calls
    isMoving = true;
    
    % Take over window mouse events
    WBMU = get(HostFig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
    
    %Change window motion and button down function
    set(HostFig,'WindowButtonMotionFcn',@(hSrc,hData) LocalMove('acquire',Constr),...
        'WindowButtonUpFcn',@(hSrc,hData) LocalMove('finish',Constr)); 

    % Start recording move
    TransAction = ctrluis.transaction(Constr.Data,'Name',xlate('Move Constraint'),...
       'OperationStore','on','InverseOperationStore','on','Compression','on');

case 'acquire'
    % Move selected objects
    % RE: Disregard single WBM event issued when adjusting pointer location
    if MoveCounter
       % Move selected objects (issues MouseEdit event)
       Status = EventMgr.moveselect('track');
       EventMgr.poststatus(Status);
    end
    MoveCounter = MoveCounter+1;
    
case 'finish'
    % Restore initial conditions
    set(HostFig,{'WindowButtonMotionFcn','WindowButtonUpFcn'},WBMU,'Pointer','arrow')
    
    % Finish move
    Status = EventMgr.moveselect('finish');
    isMoving = false;
    if MoveCounter>1 && ~isempty(TransAction)
       % Record transaction and update status
       EventMgr.record(TransAction);
       EventMgr.newstatus(Status);
       % Issue DataChanged even to force full observer update 
       Constr.send('DataChanged');
       Constr.send('DataChangeFinished');
    end
    TransAction = [];   % release persistent object
end

%%%%%%%%%%%%%%%%%
% LocalResize   %
%%%%%%%%%%%%%%%%%
function LocalResize(Constr,action)
% Resizes gain constraint when button down on end marker

persistent WBMU TransAction isResizing

EventMgr = Constr.EventManager;    % @eventmgr object
hGroup   = Constr.Elements;
HostAx   = handle(hGroup.Parent);
HostFig  = HostAx.Parent;

switch action
   case 'init'
      if isResizing
         %Another key pressed while resizing, stop resizing
         LocalResize(Constr,'finish');
         return
      end

      CP = get(HostAx,'CurrentPoint');

      % Initialize constraint resizing algorithm
      setptr(HostFig,'closedhand');

      % Select constraint
      EventMgr.clearselect;   % resize is always single-select
      Constr.Selected = 'on';
      isResizing = true;

      % Switch to mouse edit mode (ensures quick update with no axis limit adjustment)
      EventMgr.MouseEditMode = 'on';

      % Find if left or right marker is being moved, and initialize resize
      CPX = unitconv(CP(1,1),Constr.xDisplayUnits,Constr.xUnits);
      CPY = unitconv(CP(1,2),Constr.yDisplayUnits,Constr.yUnits);
      Dist = (Constr.xCoords - CPX).^2 + (Constr.yCoords - CPY).^2;
      [Constr.SelectedEdge,markerend] = find(Dist==min(min(Dist)),1);
      Constr.resize('init',markerend);

      % Take over window mouse events
      WBMU = get(HostFig,{'WindowButtonMotionFcn','WindowButtonUpFcn','KeyPressFcn'});
      set(HostFig,'WindowButtonMotionFcn',@(hSrc,hData) LocalResize(Constr,'acquire'),...
         'WindowButtonUpFcn',@(hSrc,hData) LocalResize(Constr,'finish'), ...
         'KeyPressFcn',@(hSrc,hData) LocalKeyPress(hData,Constr,markerend));
      % Start recording
      TransAction = ctrluis.transaction(Constr.Data,'Name',xlate('Resize Constraint'),...
         'OperationStore','on','InverseOperationStore','on','Compression','on');

   case 'acquire'
      % Call to get X and Y values during constraint resize
      % RE: RESIZE should issue MouseEdit event with proper data for axes rescale
      Constr.resize('acquire');

   case 'finish'
      
      % Restore initial conditions
      set(HostFig, {'WindowButtonMotionFcn', 'WindowButtonUpFcn','KeyPressFcn'}, ...
         WBMU, 'Pointer', 'arrow')

      % Call to finish resize
      Constr.resize('finish');
      EventMgr.MouseEditMode = 'off';
      isResizing = false;
      
      % Record transaction
      EventMgr.record(TransAction);
      TransAction = [];   % release persistent object
      
      % Issue DataChanged even to force full observer update
      Constr.send('DataChanged');
      Constr.send('DataChangeFinished');
end

%--------------------------------------------------------------------------
function LocalKeyPress(hData,Constr,markerend)
%Action for when key pressed in constraint resize mode

if strcmpi(hData.Key,'shift')
   LocalResize(Constr,'finish')
   Constr.snap(markerend);
end

%--------------------------------------------------------------------------
function iEdge = localFindSelectedEdge(X,Y,Tp)

%Create parametric lines for all segments
Slope = [diff(X,[],2), diff(Y,[],2)];
mSlope = sum(Slope.^2,2); %Slope magnitude
Xp = Tp(1)-X(:,1);    %Shift origin to startpoint of edge
Yp = Tp(2)-Y(:,1);    %Shift origin to startpoint of edge
r = (Xp.*Slope(:,1)+Yp.*Slope(:,2))./mSlope;  %Closest point on edge to test point
r = max(min(r,1),0);   %limit to line extents
Xl = r.*Slope(:,1);    %Closest point on edge
Yl = r.*Slope(:,2);    %Closest point on edge

%Compute distances
Dist = (Xp-Xl).^2+(Yp-Yl).^2;   %Distance of test point to each edge

iEdge = find(Dist == min(Dist),1,'first');
