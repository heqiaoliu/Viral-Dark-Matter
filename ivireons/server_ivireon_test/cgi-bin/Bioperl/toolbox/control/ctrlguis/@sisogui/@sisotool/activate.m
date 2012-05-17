function activate(sisodb,varargin)
% Activates GUI menus and tools.

%   $Revision: 1.8.4.2 $  $Date: 2005/12/22 17:43:55 $
%   Copyright 1986-2003 The MathWorks, Inc.

HG = sisodb.HG;

% Enable toolbar icons (except help, monitored on its own)
set(HG.Toolbar(1:end-1),'Enable','on')

% Enable figure menus and controls
set(get(HG.Menus.File.Top,'Children'),'Enable','on')
set(get(HG.Menus.Edit.Top,'Children'),'Enable','on')
set(get(HG.Menus.View.Top,'Children'),'Enable','on')
set(get(HG.Menus.Analysis.Top,'Children'),'Enable','on')
set(get(HG.Menus.Tools.Top,'Children'),'Enable','on')
set(get(HG.Menus.Compensator.Top,'Children'),'Enable','on')

% Disable undo/redo (have their own state management)
set([HG.Menus.Edit.Undo;HG.Menus.Edit.Redo],'Enable','off')

