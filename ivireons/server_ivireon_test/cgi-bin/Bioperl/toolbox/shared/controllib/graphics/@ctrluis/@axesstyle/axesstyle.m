function h = axesstyle(ax)
% Returns instance of @axesstyle class

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:08 $

% RE: Optimized for speed

% Create @axesstyle instance 
h = ctrluis.axesstyle;

% Initialize with properties of supplied axes
if nargin
   ax = handle(ax);
   h.Color = ax.Color;
   h.FontAngle = ax.FontAngle;
   h.FontSize = ax.FontSize;
   h.FontWeight = ax.FontWeight;
   h.XColor = ax.XColor;
   h.YColor = ax.YColor;
end

% Listener to style changes
c = classhandle(h);
h.Listener = handle.listener(h,c.Properties(1:6),'PropertyPostSet',@LocalUpdateStyle);


%---------------------- Local Functions --------------------

function LocalUpdateStyle(eventsrc,eventdata)
% Evaluate the update fcn
h = eventdata.AffectedObject;
if ~isempty(h.UpdateFcn)
   feval(h.UpdateFcn{1},eventsrc,eventdata,h.UpdateFcn{2:end});
end
