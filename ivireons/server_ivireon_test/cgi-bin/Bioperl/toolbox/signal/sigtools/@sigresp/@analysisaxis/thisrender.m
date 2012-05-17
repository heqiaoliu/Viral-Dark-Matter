function varargout = thisrender(this, hax, varargin)
%THISRENDER Render and draw the analysis

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2009/01/05 18:01:50 $ 

createdynamicprops(this);

if nargin == 1,
    h.axes = newplot;
else
    
    % Remove all non handles from the vector.
    hax(~ishghandle(hax)) = [];

    % Find the axes
    h.axes = findobj(hax, 'type', 'axes');
    if isempty(h.axes),
        if ishghandle(hax, 'figure'),
            
            % If there is no axes on the figure, create a new one.
            h.axes = axes('Parent', hax);
        else
            h.axes = newplot;
        end
    end
end

hFig = ancestor(h.axes(1), 'figure');
set(this, 'FigureHandle', hFig);

set(this, 'Handles', h);

if nargout,
    [varargout{1:nargout}] = draw(this, varargin{:});
else
    draw(this, varargin{:});
end

attachlisteners(this); % Call the method that can be overloaded.
lclattachlisteners(this, varargin{:}); % Call the local method that cannot be overloaded.

% ---------------------------------------------------------------------
function lclattachlisteners(this, varargin)

l = [ ...
        handle.listener(get(this, 'Parameters'), 'NewValue', ...
        {@parameter_listener, varargin{:}}); ...
        handle.listener(this, this.findprop('Legend'), 'PropertyPostSet', ...
        @legend_listener); ...
        handle.listener(this, this.findprop('Grid'), 'PropertyPostSet', ...
        @grid_listener); ...
        handle.listener(this, this.findprop('Title'), 'PropertyPostSet', ...
        @title_listener); ...
        handle.listener(this, this.findprop('FastUpdate'), 'PropertyPostSet', ...
        @title_listener); ...
    ];

set(l, 'CallbackTarget', this);

set(this, 'UsesAxes_WhenRenderedListeners', l);

% ---------------------------------------------------------------------
function title_listener(this, eventData)

ht = get(getbottomaxes(this), 'Title');

if strcmpi(get(this, 'Visible'), 'on'),
    titleVis = get(this, 'Title');
else
    titleVis = 'off';
end
set(ht, 'visible', titleVis);

% ---------------------------------------------------------------------
function grid_listener(this, eventData)

updategrid(this);

% ---------------------------------------------------------------------
function legend_listener(this, eventData)

updatelegend(this);

% ---------------------------------------------------------------------
function parameter_listener(this, eventData)

sendstatus(this, 'Computing Response ...');
changedtags = cellstr(get(eventData, 'Data'));

% If any of the changed tags are removed at least 1 was there.
xchanged = length(changedtags) ~= length(setdiff(changedtags, getxparams(this)));
ychanged = length(changedtags) ~= length(setdiff(changedtags, getyparams(this)));

% If all the tags are "zoom" tags then keep the zoom state.
if xchanged && ychanged, draw(this);
elseif xchanged,         captureanddraw(this, 'y');
elseif ychanged,         captureanddraw(this, 'x');
else,                    draw(this); % captureanddraw(this, 'both');
end

sendstatus(this, 'Computing Response ... done');

% ---------------------------------------------------------------------
function createdynamicprops(this)

p = [ ...
        schema.prop(this, 'UsesAxes_WhenRenderedListeners', 'handle.listener vector'); ...
        schema.prop(this, 'UsesAxes_RenderedPropHandles', 'schema.prop vector'); ...
    ];

set(p, 'Visible', 'Off');
set(this, 'UsesAxes_RenderedPropHandles', p);

% [EOF]
