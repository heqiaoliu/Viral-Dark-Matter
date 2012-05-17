function shiftAxes(h,ax,point,mode)

% Copyright 2006 The MathWorks, Inc.

if strcmp(mode,'motion')
   % If a hover point is specified, move selected wave to the hovering position
   if ~isempty(point)
       delta = point(:)-h.Plot.selectionStruct.HoverPoint;
       h.Plot.selectionStruct.HoverPoint = point(:);
       h.Plot.selectionStruct.Selectedwave.Data.shiftLine(h.Plot.selectionStruct.Selectedline,delta(2));
   end
   % If no axes is specified, create a new one. If an axes is defined other
   % than the starting axes of the selected line then move the line to the
   % new axes
   if isempty(ax)
       rowinds = h.Plot.selectionStruct.Selectedwave.RowIndex;
       rowinds(h.Plot.selectionStruct.Selectedline) = length(h.Plot.getaxes)+1; 
       h.refreshAxes(h.Plot.selectionStruct.Selectedwave,rowinds);
   elseif (ax~=h.Plot.selectionStruct.Selectedaxes)
       h.Plot.selectionStruct.Selectedaxes = ax;
       rowinds = h.Plot.selectionStruct.Selectedwave.RowIndex;
       rowinds(h.Plot.selectionStruct.Selectedline) = find(h.Plot.getaxes==ax);  
       h.Plot.selectionStruct.Selectedwave.RowIndex = rowinds;
   end
   
   % Redraw
   h.Plot.selectionStruct.Selectedwave.RefreshMode = 'quick';
   h.Plot.selectionStruct.Selectedwave.draw;
elseif strcmp(mode,'complete') && ~isempty(h.Plot.selectionStruct.Selectedwave)     
   % Consolidate any empty axes and refresh all legends
   h.Plot.packAxes;
   h.Plot.AxesGrid.refreshlegends;
   % Clear selection
   set(h.Plot.selectionStruct.Selectedwave.View.Curves,'Selected','off')
   h.Plot.selectionStruct.Selectedwave.Data.clearwatermark;
   
   % Reset the Data amplitude to match the timeseries data
   h.Plot.selectionStruct.Selectedwave.DataSrc.send('SourceChange');
end