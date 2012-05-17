function str = maketip(this,event_obj,info)
%MAKETIP  Build data tips for @timeview curves.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:27:38 $

r = info.Carrier;
AxGrid = info.View.AxesGrid;

pos = get(event_obj,'Position');
Y = pos(2);
X = pos(1);

if strcmp(AxGrid.YNormalization,'on')
   ax = event_obj.getaxes;
   Y = denormalize(info.Data,Y,get(ax,'XLim'),info.Row,info.Col);
end
   
% Create tip text
str{1,1} = sprintf('Response: %s',r.Name);
[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col);
if any(AxGrid.Size(1:2)>1) | ShowFlag
   % Show if MIMO or non trivial
   str{end+1,1} = iotxt;
end
str{end+1,1} = sprintf('Time (%s): %0.3g', AxGrid.XUnits, X);
str{end+1,1} = sprintf('Amplitude: %0.3g', Y);

