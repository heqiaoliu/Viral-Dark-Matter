function handles = renderMenu(this)
%RENDERMENU Render the menu bar of eye diagram scope GUI

%   @commscope/@eyediagramgui
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:22:56 $

% Render file menu
handles.FileMenu = renderFileMenu(this);

% Render options menu
handles.OptionsMenu = renderOptionsMenu(this);

% Render view menu
handles.ViewMenu = renderViewMenu(this);

% Render help menu
renderHelpMenu(this);

%-------------------------------------------------------------------------------
% [EOF]
