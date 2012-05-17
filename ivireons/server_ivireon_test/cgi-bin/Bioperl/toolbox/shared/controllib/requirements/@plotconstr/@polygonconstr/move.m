function [X,Y] = move(Constr,action,X,Y,X0,Y0)
%MOVE  Moves constraint
% 
%   [X0,Y0] = CONSTR.MOVE('init',X0,Y0) initialize the move. The 
%   pointer may be slightly moved to sit on the constraint edge
%   and thus eliminate distortions due to patch thickness.
%
%   [X,Y] = CONSTR.MOVE('restrict',X,Y,X0,Y0) limits the displacement
%   to locations reachable by CONSTR.
%
%   STATUS = CONSTR.MOVE('update',X,Y,X0,Y0) moves the constraint.
%   For constraints indirectly driven by the mouse, the update is
%   based on a displacement (X0,Y0) -> (X,Y) for a similar constraint 
%   initially sitting at (X0,Y0).

%   Author(s): N. Hickey, P. Gahinet, A. Stothert
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:47 $

% RE: Incremental move is not practical because the constraint cannot
%     track arbitrary mouse motion (e.g., enter negative gain zone)

switch action
case 'init'
   % Initialization, model is
   %    xValue = xValue0 + (X-X0)
   %    yValue = yValue0 + (Y-Y0)
   iEdge                  = Constr.SelectedEdge;
   Constr.AppData.xValue0 = unitconv(Constr.xCoords(iEdge,:),...
      Constr.xUnits,Constr.getDisplayUnits('XUnits'));
   Constr.AppData.yValue0 = unitconv(Constr.yCoords(iEdge,:),...
      Constr.yUnits,Constr.getDisplayUnits('YUnits'));
case 'restrict'
   %If part of a bound, check to prevent move beyond neighbours extremes.
   [X,Y] = Constr.limitMove(X,Y,X0,Y0);
   
case 'update'
   iElement = Constr.SelectedEdge;
   
   % Update yCoord, turn off listeners.
   Constr.yCoords(iElement,:) = unitconv(Constr.AppData.yValue0 + (Y-Y0),...
      Constr.getDisplayUnits('YUnits'),Constr.yUnits);
   
   % Update xCoord, leave listeners on to fire updates and redraws.
   Constr.xCoords(iElement,:) = unitconv(Constr.AppData.xValue0 + (X-X0), ...
      Constr.getDisplayUnits('XUnits'),Constr.xUnits);
   
   %Manually force coordinate updates and redraw
   Constr.Data.updateCoords(Constr.Orientation,false);
   Constr.update;
   
   % Status
   X = Constr.moveStatus;
   
case 'finish'
   %Notify listeners of data source change
   Constr.Data.send('DataChanged');
end

