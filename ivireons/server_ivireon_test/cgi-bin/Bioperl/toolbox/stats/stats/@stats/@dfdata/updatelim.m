function updatelim(h)
%UPDATELIM Update plotting limits for this data set

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:21:50 $
%   Copyright 2003-2008 The MathWorks, Inc.

% Get limits from plotted points
h.xlim = [min(h.plotx) max(h.plotx)];
ylim = [min(h.ploty) max(h.ploty)];

% Consider bounds as well
if ~isempty(h) && ishandle(h) && all(ishghandle(h.boundline))
   ydata = get(h.boundline,'YData');
   if ~isempty(ydata)
      ylim = [min(ylim(1), min(ydata)),   max(ylim(2),max(ydata))];
   end
end

h.ylim = ylim;
