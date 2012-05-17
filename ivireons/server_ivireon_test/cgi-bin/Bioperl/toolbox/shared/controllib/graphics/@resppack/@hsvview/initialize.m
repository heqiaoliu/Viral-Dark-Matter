function initialize(this, Axes)
%INITIALIZE  Initializes @hsvview objects.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:21:13 $

h = specgraph.barseries('XData',[],'YData',[],...
   'Parent', Axes, 'Visible', 'off', 'EdgeColor',[.8 0 0],'FaceColor',[.8 0 0],...
   'DisplayName','Unstable modes');
set(h,'BarPeers',h)
this.InfiniteSV = h;

h = specgraph.barseries('XData',[],'YData',[],...
   'Parent', Axes, 'Visible', 'off', 'EdgeColor',[0 0 .6],'FaceColor',[0 0 .6],...
   'DisplayName','Stable modes');
set(h,'BarPeers',h)
this.FiniteSV = h;

