function setgridstyle(this,Prop,Value)
%SETGRIDCOLOR  Updates style of grid lines and labels.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:15:37 $

GH = this.GridLines(ishghandle(this.GridLines));
switch Prop
case 'Color'
    set(findobj(GH,'Type','line'),'Color',Value)
    set(findobj(GH,'Type','text'),'Color',0.5*Value)
end