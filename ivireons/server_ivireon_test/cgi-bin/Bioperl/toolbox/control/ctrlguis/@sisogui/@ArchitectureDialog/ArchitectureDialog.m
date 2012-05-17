function h = ArchitectureDialog(sisodb)
%ArchitectureDialog  Constructor

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2006/05/27 18:02:28 $

h = sisogui.ArchitectureDialog;

h.Parent = sisodb;

h.sync;

h.build;

h.Figure.Visible = 'on';