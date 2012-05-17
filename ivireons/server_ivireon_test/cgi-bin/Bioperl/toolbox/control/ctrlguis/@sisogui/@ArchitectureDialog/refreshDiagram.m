function refreshDiagram(this)
% Updates the block diagram

%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2006/06/20 20:02:03 $

ConfigData = this.ConfigData;

%% Refresh Diagram Axes
A = this.DiagramAxes;
cla(A);
Diagram = loopstruct(A, ConfigData, 'labels', []);

