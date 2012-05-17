function resize(Constr,action,SelectedMarkerIndex)
%RESIZE  Keeps track of gain constraint whilst resizing.

%   Author(s): A. Stothert
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:50 $

persistent Yinit Xinit sty mve Slope 
persistent MouseEditData

MagAxes  = handle(Constr.Elements.Parent);
EventMgr = Constr.EventManager;

% Process event
switch action
case 'init'
   % Initialize RESIZE
   MouseEditData = ctrluis.dataevent(EventMgr,'MouseEdit',[]);
   
   % Convert the constraint line Y into dB
   iEdge = Constr.SelectedEdge;
   Yinit = Constr.yCoords(iEdge,:);
   Xinit = Constr.xCoords(iEdge,:);
   mve   = SelectedMarkerIndex;      % 1 if left marker moved, 2 otherwise
   sty   = 3 - SelectedMarkerIndex;
   
   % Initialize axes expand
   moveptr(MagAxes,'init');
   
case 'acquire'    
   % Track mouse location
   CP  = get(MagAxes,'CurrentPoint');
   CPX = unitconv(CP(1,1),Constr.xDisplayUnits,Constr.xUnits);
   CPY = unitconv(CP(1,2),Constr.yDisplayUnits,Constr.yUnits);
     
   %Prevent move beyond limits of neighbours
   [CPX,CPY] = Constr.limitResize(CPX,CPY,mve);
         
   % Calculate new slope of constraint line
   Slope = [ -(Xinit(sty) - CPX), -(Yinit(sty) - CPY)]; %Parameterize to avoid inf slope problems

   % Update the constraint X and Y data properties
   Xinit(mve) = CPX;
   Yinit(mve) = CPY;
   localUpDate(Constr,Xinit,Yinit);

   % Adjust axis limits if moved constraint gets out of focus
   % Issue MouseEdit event and attach updated extent of resized objects (for axes rescale)
   Extent = Constr.extent;
   MouseEditData.Data = ...
      struct('XExtent',Extent(1:2),'YExtent',Extent(3:4),'X',CP(1,1),'Y',CP(1,2));
   EventMgr.send('MouseEdit',MouseEditData)

   % Update status bar with gradient of constraint line
   EventMgr.poststatus(Constr.resizeStatus);
   
case 'finish'
   % Clean up
   MouseEditData = [];
 
   % Update the constraint X and Y data properties
   if numel(Slope) == 2
      Yinit(mve) = Yinit(sty) + Slope(2);
   end
   localUpDate(Constr,Xinit,Yinit);
      
   % Update status
   EventMgr.newstatus(Constr.status('resize'));
   
   %Notify listeners of data source change
   Constr.Data.send('DataChanged');
   
end

%--------------------------------------------------------------------------
function localUpDate(Constr,Xinit,Yinit)
% Calculate and update the constraint X and Y data properties

%Set Y values, disable listeners.
iEdge     = Constr.SelectedEdge;
Constr.yCoords(iEdge,:) = Yinit;
Constr.xCoords(iEdge,:) = Xinit;

%Manually force co-ord update and redraw
Constr.Data.updateCoords(Constr.Orientation,false)
Constr.update