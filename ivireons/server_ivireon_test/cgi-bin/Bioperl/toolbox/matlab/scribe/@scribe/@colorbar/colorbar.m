function h=colorbar(varargin)
%COLORBAR creates the scribe colorbar object

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4.2.37.2.1

ax = [];
par = [];

if (nargin == 0) || ischar(varargin{1})
    parind = find(strcmpi(varargin,'parent'));
    if isempty(parind)
        par = gcf;
        fig = par;
    else
        par = varargin{parind(end)+1};
        fig = ancestor(par,'Figure');
    end
else
    ax = varargin{1};
    par = get(ax,'Parent');
    fig = ancestor(ax,'figure');
    location = varargin{2};
    position = varargin{3};
    varargin(1:3) = [];
end

% be sure nextplot is 'add'
oldNextPlot = get(fig,'NextPlot');
if strcmp(oldNextPlot,'replacechildren') || strcmp(oldNextPlot,'replace')
    set(fig,'NextPlot','add');
end
h = scribe.colorbar('Parent',par,'Units','normalized','visible','off','Interruptible','off');
b = hggetbehavior(double(h),'Pan');
set(b,'Enable',false);
b = hggetbehavior(double(h),'Zoom');
set(b,'Enable',false);
b = hggetbehavior(double(h),'Rotate3D');
set(b,'Enable',false);
b = hggetbehavior(double(h),'DataCursor');
set(b,'Enable',false);
b = hggetbehavior(double(h),'Plotedit');
set(b,'MouseOverFcn',methods(h,'getfunhan','-noobj','mouseover'));
set(b,'ButtonDownFcn',methods(h,'getfunhan','-noobj','bdown'));
set(b,'KeepContextMenu',true);
set(b,'AllowInteriorMove',true);
set(b,'EnableCopy',false);

if ~isappdata(0,'BusyDeserializing')

    if isempty(ax)
        ax = get(fig,'CurrentAxes');
        if isempty(ax)
            ax = axes('parent',fig);
        end
    end

    set(double(h),'Tag','Colorbar');
    h.Location = location;
    h.Axes = ax;
    h.BaseColormap = get(fig,'Colormap');

    % customize colorbar behavior for tools
    setappdata(double(h),'NonDataObject',[]);
    setappdata(double(h),'PostDeserializeFcn',graph2dhelper('colorbarpostdeserialize'));

    % THE AXES
    cbarax = double(h);
    set(cbarax,'Box', 'on');

    set(fig,'NextPlot',oldNextPlot);

    h.methods('initialize_colorbar_properties',fig,ax);

    % init position before listeners are set up (why?)
    if ~isempty(position) && length(position)==4
        set(double(h),'Position',position);
    end

    % colorbars need to check for subplots in order to keep
    % the plot box sizes the same around the edges. Throw
    % the subplots into Position mode to ignore the edge gaps.
    % The subplots will end up in Position mode anyway.
    if isappdata(ax,'SubplotInsets')
        set(ax,'ActivePositionProperty','position');
        reset = true;
        if isprop(ax,'LegendColorbarOuterList')
            list = get(ax,'LegendColorbarOuterList');
            list(~ishandle(list)) = [];
            reset = isempty(list);
        end
        if reset
            set(ax,'LooseInset',get(fig,'DefaultAxesLooseInset'))
        end
    end

    % setup listeners, among other things
    h.init();

    % explicitly call this because listeners were not setup when Location
    % was set above.  Going forward this will run any time the Orientation
    % changes.
    methods(h,'setConfiguration', ax);

    % set other properties from varargin
    set(h,varargin{:});
    set(fig,'currentaxes',ax);
end

set(double(h),'visible','on');
set(double(h.Image),'visible','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resetCurrentAxes(hSrc, evdata) %#ok<INUSD,DEFNU>
% This function (resetCurrentAxes) is a dummy stub required to load a fig
% file saved in R14SP1.  In R14SP1, the handle to the buttondown function
% (which used to be this function) was saved.  Hence need to have this
% dummy stub.  Even in the case of loading an R14SP1 fig file, the correct
% buttondown function will be set in the 'init' method.