function layout(this)
% Positions tab elements

%   Authors: P. Gahinet and Bill York
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:09 $

%RE: All positions must be computed as integer pixel values to get sharp edge

% Tab geometry in figure units
pos = this.Position ./ [this.Pix2Unit this.Pix2Unit];
xchar2pix = this.Char2Unit(1)/this.Pix2Unit(1);
ychar2pix = this.Char2Unit(2)/this.Pix2Unit(2);
tabx = round(xchar2pix * this.TabOffset);
tabw = round(xchar2pix * this.TabWidth);
tabh = round(ychar2pix * this.TabHeight);
s = 1; % one pixel 

% Positioning parameters
pos(4) = pos(4)-tabh;
l = pos(1);
b = pos(2);
t = b + pos(4);
r = l + pos(3);
w = pos(3);
h = pos(4); % panel height

% Lay out panel (only needs to be done for selected tab)
if strcmp(this.Selected,'on')
   set(this.Panel(1),'pos',[l b s h])
   set(this.Panel(2),'pos',[l+s b s h])
   set(this.Panel(3),'pos',[l b w s])
   set(this.Panel(4),'pos',[l+s b+s w-2*s s])
   set(this.Panel(5),'pos',[r-s b s h])
   set(this.Panel(6),'pos',[r-2*s b+s s h-2*s])
   set(this.Panel(7),'pos',[l+tabx+tabw+s t-3*s w-tabx-tabw-s 2*s])
   set(this.Panel(8),'pos',[l+tabx+tabw t-s w-tabx-tabw s])
   if tabx>0
      set(this.Panel(9),'pos',[l+s t-3*s tabx-s 2*s])
      set(this.Panel(10),'pos',[l t-s tabx s])
   else
      set(this.Panel(9),'pos',[l t s s])
      set(this.Panel(10),'pos',[l+s t s s])
   end
end

% Lay out tab
set(this.TabLeftEdge(1),'pos',[l+tabx t s tabh])
set(this.TabLeftEdge(2),'pos',[l+tabx+s t s tabh])

set(this.TabRightEdge(1),'pos',[l+tabx+tabw-s t s tabh])
set(this.TabRightEdge(2),'pos',[l+tabx+tabw-2*s t+s s tabh-2*s])

set(this.TabTopEdge(1),'pos',[l+tabx+s t+tabh-3*s tabw 2*s])
set(this.TabTopEdge(2),'pos',[l+tabx t+tabh-s tabw s])

set(this.Label,'pos',[l+tabx+1 t+0.1*tabh tabw-4*s 0.66*tabh])


