function children = gethchildren(h)
%GETHCHILDREN gets the wrappable subsystems beneath this node

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/05/20 02:18:27 $

% Get thte SF object that the node points to. 
chart = fxptui.sfchartnode.getSFChartObject(h.daobject);
children = chart.getHierarchicalChildren;
children = fxptui.filter(children);

% [EOF]
