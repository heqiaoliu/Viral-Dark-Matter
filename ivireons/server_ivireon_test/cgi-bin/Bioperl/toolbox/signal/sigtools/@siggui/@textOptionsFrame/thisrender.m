function thisrender(this, varargin)
%THISRENDER  Renders the text frame with the default values.
%   THISRENDER(H, HFIG, POS)
%   H       -   Handle to object
%   HFIG    -   Handle to parent figure
%   POS     -   Position of frame
%   Since the textOptionsFrame may be a superclass, it's render method
%   must be callable from subclasses hence all the code necessary to
%   actually render the frame is moved to another method

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $  $Date: 2008/05/31 23:28:23 $

% Render the container frame and return values needed for every render method
renderabstractframe(this, varargin{:});

h    = get(this, 'Handles');
hFig = get(this, 'FigureHandle');
sz   = gui_sizes(this);

framePos = get(h.framewlabel(1), 'Position');

% Calculate the position of the text.
pos(1) = framePos(1) + sz.hfus;
pos(2) = framePos(2) + sz.vfus;
pos(3) = framePos(1) + framePos(3) - pos(1) - sz.hfus;
pos(4) = framePos(2) + framePos(4) - 2*sz.vfus - pos(2);

h.text = uicontrol('Style','Text',...
    'horizontalalignment','left',...
    'String',get(this,'Text'),...
    'backgroundcolor',get(0, 'defaultuicontrolbackgroundcolor'),...
    'enable','on',...
    'visible','off',...
    'units','pixels',...
    'position',pos,...
    'Parent',hFig);

% Install text listener
listener(1) = handle.listener(this, this.findprop('Text'),...
    'PropertyPostSet',@text_listener);

% Set the callback target
set(listener,'callbacktarget',this);

% Store the listener
set(this, 'WhenRenderedListeners',listener);
set(this, 'handles', h);

% [EOF]
