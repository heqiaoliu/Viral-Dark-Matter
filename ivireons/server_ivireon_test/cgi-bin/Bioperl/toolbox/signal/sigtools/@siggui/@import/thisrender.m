function thisrender(hIT, varargin)
%THISRENDER Render the Import Tool

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.17.4.8 $  $Date: 2009/07/14 04:03:36 $

error(nargchk(1,3,nargin,'struct'));

pos = parserenderinputs(hIT, varargin{:});
sz  = import_gui_sizes(hIT, pos);

h.frame  = render_frame(hIT, sz);
h.button = render_button(hIT, sz);

set(hIT,'Handles',h);

render(getcomponent(hIT, '-class', 'siggui.coeffspecifier'), ...
    hIT.FigureHandle, sz.structpop);
render(getcomponent(hIT, '-class', 'siggui.fsspecifier'), ...
    hIT.FigureHandle, sz.fslabel);


% ----------------------------------------------------------------
function hframe = render_frame(hIT, sz)

% Uicontrol sizes and spaces
bgc  = get(0,'defaultuicontrolbackgroundcolor');
hFig = get(hIT,'FigureHandle');

% Render the Specify Filter Coefficients frame
hframe = framewlabel(hFig,sz.frame,'Filter Coefficients',...
    'import_frame',bgc, 'Off');

fdaddcontextmenu(hFig, hframe, 'fdatool_importfiltercoefficients_frame');

% ----------------------------------------------------------------
function hbutton = render_button(hIT, sz)
% Render the action button

hFig = get(hIT,'FigureHandle');

string = 'Import Filter';
pos = getButtonPosition(hIT,sz,string);
cbs = siggui_cbs(hIT);

hbutton = uicontrol(hFig, ...
    'Units', 'Pixels', ...
    'Position', pos, ...
    'String', string, ...
    'Tag', 'import_action_button', ...
    'Visible', hIT.Visible, ...
    'Callback', {cbs.method, hIT, @importfilter});

fdaddcontextmenu(hFig, hbutton, 'fdatool_import_filter_button');

% ----------------------------------------------------------------
function pos = getButtonPosition(hIT,sz,string)
%Calculate the action button position

width = largestuiwidth({string})+20*sz.pixf;

pos = sz.button;
pos(3) = width;
pos(1) = pos(1)-width/2;

% ----------------------------------------------------------------
function sz = import_gui_sizes(hIT, pos)

sz = gui_sizes(hIT);

if isempty(pos),
    pos = [34 8 732 248] * sz.pixf; 
end

sz.frame     = pos + [sz.ffs sz.vffs+sz.bh -2*sz.ffs -2*sz.vffs-sz.bh];
sz.button    = [sz.frame(1)+sz.frame(3)/2 pos(2)+sz.vffs/2 0 sz.bh];
sz.structpop = [sz.frame(1)+sz.hfus, ...
        sz.frame(2)+sz.vfus, ...
        sz.frame(3)*.75, ...
        sz.frame(4)-2*sz.vfus];
sz.fslabel   = [.75*sz.frame(3)+sz.uuhs sz.frame(2)+sz.frame(4)-(3*sz.uh+2*sz.uuvs+sz.vfus) ...
    160*sz.pixf 3*sz.uh+sz.uuvs];

if isunix, sz.fslabel(1) = sz.fslabel(1)-20*sz.pixf; end

% [EOF]
