function h = tooleditor(Dialog,Container)
%TOOLEDITOR  Constructor for @tooleditor adapter.

%   Authors: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:18 $

h = plotconstr.tooleditor;
h.Dialog = Dialog;  % @tooldlg handle
h.Container = Container;