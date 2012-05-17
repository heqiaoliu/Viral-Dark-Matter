function thisrender(this, varargin)
%RENDER renders the UI components of the class
%   RENDER(H, HFIG, POS)
%   H       -   The handle to the object
%   HFIG    -   The handle to the figure into which to place the frame
%   POS     -   The position of the frame

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.4 $  $Date: 2008/05/31 23:28:26 $

pos = parserenderinputs(this, varargin{:});

% If hFig is not specified, create a new figure
if nargin < 2 , hFig = gcf; end
if nargin < 3 , pos = 'mag'; end

% Call the super classes render method
super_render(this, pos);

h    = get(this, 'handles');
hFig = get(this, 'FigureHandle');
sz   = gui_sizes(this);
pos  = getpixelpos(this, 'framewlabel', 1);

h.units = uicontrol(hFig, ...
    'Style', 'Text', ...
    'position',[pos(1)+sz.hfus+10*sz.pixf pos(2) + pos(4) - 2.5*(sz.vfus + sz.uh) ...
        largestuiwidth({'12345'}) + 10*sz.pixf + sz.ebw 2*sz.uh],...
    'visible','off',...
    'horizontalalignment','left',...
    'String','Enter a weight value for each band below.');

set(this, 'Handles', h);

% Get the handle to the LabelsAndValues class
lvh = getcomponent(this, 'siggui.labelsandvalues');

pos = [pos(1)+sz.hfus pos(2)+sz.vfus pos(3)-3*sz.hfus pos(4)-sz.uh-sz.vfus-4*sz.uuvs];

% Render the LabelsAndValues class
render(lvh, hFig, pos);

%  Add contextsensitive help
cshelpcontextmenu(this, 'fdatool_ALL_mag_specs_frame');

% [EOF]
