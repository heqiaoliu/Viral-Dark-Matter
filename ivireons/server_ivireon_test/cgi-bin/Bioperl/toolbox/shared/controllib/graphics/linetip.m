function tip = linetip(LINE, varargin)
%LINETIP  Line tip wrapper function
%
%   h = LINETIP(LINE,'PropertyName1',value1,'PropertyName2,'value2,...) 
%   will activate linetip with the following options:
%
%      LINE:       handle of line to be scanned.
%
%

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:12:29 $

% Check valid input argument, this change is not really related to datatips
if ~ishghandle(LINE,'line')
    ctrlMsgUtils.error('Controllib:general:UnexpectedError',...
        'The first input argument of the "linetip" command must be a handle of class "line".')
end

%% Create the datatip
tip = graphics.datatip(LINE);
%% Set the Z-Stacking properties
tip.ZStackMinimum = 10;
tip.EnableZStacking = true;

%% Turn on interpolation
tip.Interpolate = 'on';
%% Set Properties
set(tip,'Visible','on',varargin{:});
%% Update and drag
update(tip);
%% Get the figure
fig = ancestor(tip,'figure');
startDrag(tip,fig);
%% Register the tip
addDataCursor(datacursormode(fig),tip);
tip.EnableAxesStacking = true;

%% Build uicontextmenu handle for marker text
ax = get(LINE,'Parent');
tip.UIContextMenu = uicontextmenu('Parent',ancestor(ax,'figure'));
%% Add the default menu items
ltitipmenus(tip,'alignment','fontsize','movable','delete','interpolation');
