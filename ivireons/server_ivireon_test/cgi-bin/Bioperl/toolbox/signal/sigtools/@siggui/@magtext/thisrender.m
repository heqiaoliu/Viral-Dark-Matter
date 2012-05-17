function thisrender(this, varargin)
%THISRENDER  Renders the magtext frame.

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/13 00:24:29 $

% If hFig is not specified, create a new figure
pos = parserenderinputs(this, varargin{:});
if isempty(pos), pos = 'mag'; end

% call the super class's render method
super_render(this, pos);

% Get the handles to the objects created
h    = get(this, 'handles');
hFig = get(this, 'FigureHandle');
sz   = gui_sizes(this);

pos = getpixelpos(this, 'framewlabel', 1);

pos = [pos(1)+sz.hfus pos(2)+sz.vfus pos(3)-2*sz.hfus pos(4)-2*sz.vfus-sz.pixf*40];

h.text = uicontrol('Style', 'text',...
    'Parent', hFig, ...
    'visible','off',...
    'Units', 'pixels',...
    'Position', pos,...
    'Horizontalalignment', 'left',...
    'string', get(this, 'text'));

set(this, 'handles', h);

% Install listener
wrl(1) = handle.listener(this, this.findprop('text'),...
    'PropertyPostSet', @text_listener);

set(wrl,'CallbackTarget',this);

% Store the listeners in the WhenRenderedListeners property of the superclass
this.WhenRenderedListeners = wrl;

% Set the units to norm
setunits(this, 'normalized');

% -------------------------------------------------------------------------
function text_listener(this, eventData)

set(this.Handles.text, 'String', this.Text);

% [EOF]
