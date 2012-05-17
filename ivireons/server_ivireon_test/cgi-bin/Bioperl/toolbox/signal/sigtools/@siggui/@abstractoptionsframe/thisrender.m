function thisrender(this, varargin)
%THISRENDER  Renders the abstract frame with the default values.
%   Since the abstractOptionsFrame is a superclass, it's render method
%   must be callable from subclasses hence all the code necessary to
%   actually render the frame is moved to another method

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2004/04/13 00:21:41 $

pos = parserenderinputs(this, varargin{:});

hFig = get(this, 'FigureHandle');

% Render the frame in the specified position.
renderabstractframe(this, hFig, pos);

pos = getpixelpos(this, 'framewlabel', 1);

% Get the properties and labels to render from the subclasses.
[props, lbls] = getrenderprops(this);

sz     = gui_sizes(this);
nprops = length(props);
h      = sz.uh*nprops+sz.uuvs*(nprops+1);
pos    = [pos(1) pos(2)+pos(4)-h pos(3) h];

rendercontrols(this, pos, props, lbls)

cshelpcontextmenu(this, getcshstring(this));

objspecific_render(this);

% [EOF]
