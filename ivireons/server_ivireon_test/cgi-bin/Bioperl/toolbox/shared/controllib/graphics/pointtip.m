function tip = pointtip(POINT, varargin)
%POINTTIP  Creates a data tip locked to a given point.
%
%   h = POINTTIP(POINT,'PropertyName1',value1,'PropertyName2,'value2,...) 
%   will attach a data tip to the point POINT (single-point HG line).

%   Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:12:34 $

% Create linetip
try
    tip = graphics.datatip(POINT);
catch
    ctrlMsgUtils.error('Controllib:general:UnexpectedError',...
        'The first input argument of the "pointtip" command must be a handle of class "line".')
end
% Set Properties
set(tip,'Visible','on',varargin{:});
tip.ZStackMinimum = 10;
tip.EnableZStacking = true;
tip.EnableAxesStacking = true;
tip.movetofront;
if ~max(strcmpi(varargin,'X')) | isempty(varargin)
    curr = get(get(POINT,'Parent'),'CurrentPoint');
    oldpos = tip.Position;
    tip.Position = [curr(1,1),oldpos(2),oldpos(3)];    
end

if ~max(strcmpi(varargin,'Y')) | isempty(varargin)
    curr = get(get(POINT,'Parent'),'CurrentPoint');
    oldpos = tip.Position;
    tip.Position = [oldpos(1),curr(1,2),oldpos(3)];
end

%% Build uicontextmenu handle for marker text
ax = get(POINT,'Parent');
tip.UIContextMenu = uicontextmenu('Parent',ancestor(ax,'figure'));
%% Add the default menu items
ltitipmenus(tip,'alignment','fontsize','delete');
