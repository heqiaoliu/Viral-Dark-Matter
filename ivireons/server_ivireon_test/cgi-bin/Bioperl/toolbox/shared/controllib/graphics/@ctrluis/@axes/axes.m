function h = axes(hndl,varargin)
% Returns instance of @axes class
%
%   H = AXES(AXHANDLE) creates an @axes instance associated with the
%   HG axes AXHANDLE. 
%
%   H = AXES(FIGHANDLE) automatically creates the HG axes and parents 
%   them to the figure with handle FIGHANDLE.

%   Author: P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:28 $

% Create @axes instance 
h = ctrluis.axes;
h.Size = [1 1 1 1];

% Validate first input argument
if numel(hndl)~=1 || ~ishghandle(hndl)
    ctrlMsgUtils.error('Controllib:plots:axes1')
else
    hndl = handle(hndl);
end
if ishghandle(hndl,'figure')
    % Create axes
    Visibility = hndl.Visible;
    hndl = handle(axes('Parent',hndl,'units','normalized', ...
        'Visible','off','ContentsVisible','off'));
    % Position in Normalized units
    Position = hndl.Position;
elseif ishghandle(hndl,'axes')
    Visibility = hndl.Visible;
    % Position in Normalized units
    Position = hgconvertunits(ancestor(hndl,'figure'), hndl.position, hndl.units, 'normalized', hndl.parent);
    % Hide axes, consistently with h.Visible=off initially
    set(hndl,'Visible','off','ContentsVisible','off')  
else
    ctrlMsgUtils.error('Controllib:plots:axes1')
end
GridState = hndl(1).XGrid;

% Create and initialize axes array
% RE: h.Axes not used
h.Axes4d = hndl;  % array of HG axes of size GRIDSIZE
h.Axes2d = hndl;
h.Parent = hndl.Parent;
h.AxesStyle = ctrluis.axesstyle(hndl);
h.UIContextMenu = uicontextmenu('Parent',ancestor(h.Parent,'figure')); 

% Settings inherited from template axes
h.XLimMode = hndl.XLimMode;
h.XScale = hndl.XScale;
h.YLimMode = hndl.YLimMode;
h.YScale = hndl.YScale;
h.NextPlot = hndl.NextPlot;

% Turn DoubleBuffer=on to eliminate flashing with grids, labels,...
set(ancestor(h.Parent,'figure'),'DoubleBuffer','on')

% Configure axes
set(h.Axes2d,'Units','normalized','Box','on',...
   'XtickMode','auto','YtickMode','auto',...
   'Xlim',hndl.Xlim,'Ylim',hndl.Ylim,...
   'NextPlot',hndl.NextPlot,'UIContextMenu',h.UIContextMenu,...
   'XGrid','off','YGrid','off',struct(h.AxesStyle));

% Initialize properties
% RE: no listeners installed yet
h.Title = get(hndl.Title,'String');
h.XLabel = get(hndl.XLabel,'String');
h.XUnits = '';
h.YLabel = get(hndl.YLabel,'String');
h.YUnits = '';
h.TitleStyle = ctrluis.labelstyle(hndl.Title);
h.XLabelStyle = ctrluis.labelstyle(hndl.XLabel);
h.YLabelStyle = ctrluis.labelstyle(hndl.YLabel);
h.Position = Position; % RE: may be overwritten by SET below
h.LimitFcn = {@updatelims h};  % install default limit picker
h.LabelFcn = {@DefaultLabelFcn h};

% Add listeners
h.addlisteners;

% User-defined properties
% RE: Maintain h.Visible=off in order to bypass all layout/visibility computations
% (achieved by removing Visible settings from prop/value list and factoring them into
%  the VISIBILITY variable)
[Visibility,varargin] = utGetVisibleSettings(h,Visibility,varargin);
h.set('Grid',GridState',varargin{:});

% Set visibility (if Visibility=on, this initializes the position/visibility of the HG axes)
h.Visible = Visibility;

% Activate limit manager 
addlimitmgr(h);