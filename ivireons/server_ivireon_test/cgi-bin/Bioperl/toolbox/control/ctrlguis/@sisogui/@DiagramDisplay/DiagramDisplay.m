function h = configdlg(LoopData,LoopConfig)
%configdlg  Constructor

%   Authors: P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/12/22 17:41:32 $

h = sisogui.DiagramDisplay;
h.LoopConfig = LoopConfig;
h.Parent = LoopData;

h.build;
h.refreshDiagram;
h.Figure.Visible = 'on';
