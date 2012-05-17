function load(Editor,SavedData,Version)
%LOAD  Restores saved Root Locus Editor settings.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2005/12/22 17:43:23 $

% RE: 1) Editor should be made invisible prior to calling this
%        function to avoid multiple updates
%     2) Only set properties that may differ from tool prefs
Axes = Editor.Axes;
SavedData = LocalUpgrade(Editor,SavedData,Version);

% Style properties
Editor.AxisEqual = SavedData.AxisEqual;

% Labels
Axes.Title = SavedData.Title;
Axes.Xlabel = SavedData.Xlabel;
Axes.Ylabel = SavedData.Ylabel;
set(Axes.TitleStyle,SavedData.TitleStyle);
set(Axes.XlabelStyle,SavedData.XlabelStyle);
set(Axes.YlabelStyle,SavedData.YlabelStyle);

% Limits
if strcmp(SavedData.Visible,'on')
   % Beware of reloading stale units (see geck 113670)
   set(getaxes(Axes),'Xlim',SavedData.Xlim,'Ylim',SavedData.Ylim)
   Axes.XlimMode = SavedData.XlimMode;
   Axes.YlimMode = SavedData.YlimMode;
end
Axes.LimitStack = SavedData.LimitStack;

% Grid 
Editor.GridOptions = SavedData.GridOptions;
Axes.Grid = SavedData.Grid;

% Set editor visibility (will trigger full update)
Editor.Visible = SavedData.Visible;

% Constraints
Editor.loadconstr(SavedData.Constraints);


function SavedData = LocalUpgrade(Editor,SavedData,Version)
% Upgrade data format to latest version
SavedData = loadconvert(Editor,SavedData,Version);
SavedData.LimitStack = ...
      struct('Limits',SavedData.LimitStack,'Index',min(1,size(SavedData.LimitStack,1)));