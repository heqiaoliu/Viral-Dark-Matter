function resize(Constr,action,SelectedMarkerIndex)
%RESIZE  Keeps track of gain constraint whilst resizing.

%   Author(s): N. Hickey
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:31:23 $

persistent Yinit Xinit sty mve Slope X0
persistent AxesLims Xlin Ylinabs MouseEditData

hGroup   = Constr.Elements;
HostAx   = handle(hGroup.Parent);
EventMgr = Constr.EventManager;

% Process event
switch action
case 'init'
   % Initialize RESIZE
   MouseEditData = ctrluis.dataevent(EventMgr,'MouseEdit',[]);
   
   % Convert the constraint line Y into dB
   Yinit = Constr.Magnitude(Constr.SelectedEdge,:);
   Xinit = Constr.Frequency(Constr.SelectedEdge,:);
   X0    = Xinit;
   mve   = SelectedMarkerIndex;      % 1 if left marker moved, 2 otherwise
   sty   = 3 - SelectedMarkerIndex;
   
   % Axes data
   AxesLims = [HostAx.Xlim , HostAx.Ylim];
   Xlin     = strcmp(HostAx.Xscale,'linear');
   Ylinabs  = strcmp(Constr.yDisplayUnits,'abs') & strcmp(HostAx.Yscale,'linear');
   
   % Initialize axes expand
   moveptr(HostAx,'init');
   
case 'acquire'    
   % Track mouse location
   CP = get(HostAx,'CurrentPoint');
   if Xlin
      CPX = unitconv(max(CP(1,1),0.01*AxesLims(2)),Constr.xDisplayUnits,Constr.FrequencyUnits);
   else
      CPX = unitconv(CP(1,1),Constr.xDisplayUnits,Constr.FrequencyUnits);
   end
   if Ylinabs
      % Protect against negative values
      CPY = unitconv(max(CP(1,2),0.01*AxesLims(4)),Constr.yDisplayUnits,Constr.MagnitudeUnits);
   else
      CPY = unitconv(CP(1,2),Constr.yDisplayUnits,Constr.MagnitudeUnits);
   end
   
   %Prevent move beyond limits of neighbours
   [CPX,CPY] = localLimitResize(Constr,CPX,CPY,mve);
   
   % Cannot go beyond Nyquist freq.
   if Constr.Ts
      nf  = pi/Constr.Ts;
      CPX = min(CPX,(1-0.75*any(X0==nf))*nf);
   end
   
   % Calculate new slope of constraint line
   if Xinit(sty)==CPX
      Slope = 0;
   else
      Slope = (Yinit(sty) - CPY) / log10(Xinit(sty)/CPX);
   end
   
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
   LocStr = sprintf('Location:  from %0.3g to %0.3g %s',...
      Constr.Frequency(Constr.SelectedEdge,1), ...
      Constr.Frequency(Constr.SelectedEdge,2), ...
      Constr.xDisplayUnits);
   SlopeStr = sprintf('Slope:  %0.3g dB/decade',Slope);
   EventMgr.poststatus(sprintf('%s\n%s',LocStr,SlopeStr)); 
   
case 'finish'
   % Clean up
   MouseEditData = [];

   % Update the constraint X and Y data properties
   if numel(Slope) ==1
      Yinit(mve) = Yinit(sty) + Slope * log10(Xinit(mve)/Xinit(sty));
   end
   localUpDate(Constr,Xinit,Yinit);
   
   % Update status
   EventMgr.newstatus(Constr.status('resize'));
   
   %Notify listeners of data source change
   Constr.Data.send('DataChanged');
   
end


%-------------------- Callback functions -------------------
function localUpDate(Constr,Xinit,Yinit)
% Calculate and update the constraint X and Y data properties
iEdge = Constr.SelectedEdge;
Constr.Magnitude(iEdge,:) = Yinit;
Constr.Frequency(iEdge,:) = Xinit;
%Manually force coordinate updates and redraw
Constr.Data.updateCoords(Constr.Orientation,false);
Constr.update;

%--------------------------------------------------------------------------
function [CPX,CPY] = localLimitResize(Constr,CPX,CPY,mve)

%Copy coordinate to limit so that can use same code block
switch Constr.Orientation
   case 'horizontal'
      CPV = CPX;
      fldLimit = 'xCoords';
   case 'vertical'
      CPV = CPY;
      fldLimit = 'yCoords';
   case 'both'
      %Nothing to do
      return
end

%Perform the limit check
iElement = Constr.SelectedEdge;
minSize = eps;   %Percentage used to limit minimum constraint size.
switch mve
   case 1
      %Left end selected
      if size(Constr.xCoords,1)>1
         %Limit left extent to left end of next constraint
         if iElement > 1
            CPV = max(CPV,Constr.(fldLimit)(iElement-1,1)*...
               (1+minSize*sign(Constr.(fldLimit)(iElement-1,1))));
         end
      end
      %Limit right extent to right end
      CPV = min(CPV,Constr.(fldLimit)(iElement,2)*...
         (1-minSize*sign(Constr.(fldLimit)(iElement,2))));
   case 2
      %Right end selected
      if size(Constr.xCoords,1)>1
         %Limit right extent to right end of next constraint
         if iElement < size(Constr.xCoords,1)
            CPV = min(CPV,Constr.(fldLimit)(iElement+1,2)*...
               (1-minSize*sign(Constr.(fldLimit)(iElement+1,2))));
         end
      end
      %Limit left extent to left end
      CPV = max(CPV,Constr.(fldLimit)(iElement,1)*...
         (1+minSize*sign(Constr.(fldLimit)(iElement,1))));
end

%Limit correct return coordinate
switch Constr.Orientation
   case 'horizontal'
      CPX = CPV;
   case 'vertical'
      CPY = CPV;
end

