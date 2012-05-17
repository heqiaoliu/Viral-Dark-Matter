function thisrender(this, varargin)
%RENDER Render the Filter Visualization Tool
%   RENDER(this, hFig, POS) Render FVTool to the figure hFig in the frame
%   specified by the position POS.  The axes position will by 130 pixels
%   narrower and 83 pixels shorter than the frame.  It will also be 60 pixels
%   to the right and 50 pixels higher.
%
%   For example a frame position of [300 200 400 250] would result in an axes
%   position of [360 250 270 167].

%   Author(s): P. Costa & J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.16.4.7 $  $Date: 2009/01/05 18:00:51 $ 

pos = parserenderinputs(this, varargin{:});

% Use the render_component's local functions to save time.

% Render the axes of FVTool
if ~isempty(pos),
    sz = gui_sizes(this);
    pos = pos + [60 50 -130 -83]*sz.pixf;
end
render_component(this,'render_axes', pos);

% Find or create a UIToolbar to render the buttons.
render_component(this,'render_toolbar');

% Find or create an Analysis menu.
render_component(this,'render_analysis_menu',3);

% Create th toolbar buttons
render_component(this,'render_analysis_toolbar');

render_component(this,'render_viewmenu');

% Normalize all the units.
setunits(this,'Normalized');

% Install Listeners
attachlisteners(this);
listeners(this, [], 'postcurrentanalysis_listener');
listeners(this, [], 'filter_listener');

% --------------------------------------------------------------------
function attachlisteners(this)

% This should be private
h = get(this, 'Handles');

l = [ ...
        handle.listener(this,this.findprop('Filters'), ...
        'PropertyPostSet', {@listeners, 'filter_listener'}); ...
        handle.listener(this,[this.findprop('ShowReference'), ...
        this.findprop('PolyphaseView')],'PropertyPostSet', ...
        {@listeners, 'show_listener'}); ...
        handle.listener(this,this.findprop('CurrentAnalysis'), ...
        'PropertyPreSet',{@listeners, 'precurrentanalysis_listener'}); ...
        handle.listener(this,this.findprop('CurrentAnalysis'), ...
        'PropertyPostSet',{@listeners, 'postcurrentanalysis_listener'}); ...
        handle.listener(this,this.findprop('DisplayMask'), ...
        'PropertyPostSet',{@listeners, 'displaymask_listener'}); ...
        handle.listener(this, 'NewAnalysis', {@listeners, 'newanalysis_eventcb'}); ...
        handle.listener(this,this.findprop('Grid'), ...
        'PropertyPostSet',{@listeners, 'grid_listener'}); ...
        handle.listener(this,this.findprop('Legend'), ...
        'PropertyPostSet',{@listeners, 'legend_listener'}); ...
        handle.listener(this,this.findprop('FsEditable'), ...
        'PropertyPostSet',{@listeners, 'fseditable_listener'}); ...
    ];

addlistener(h.axes(1), {'XGrid' 'YGrid'}, 'PostSet', ...
    @(h, ev) listeners(this, ev, 'axesgrid_listener'));
addlistener(h.axes(2), {'XGrid' 'YGrid'}, 'PostSet', ...
    @(h, ev) listeners(this, ev, 'axesgrid_listener'));

set(l,'CallbackTarget',this);
set(this,'WhenRenderedListeners',l);

% [EOF]
