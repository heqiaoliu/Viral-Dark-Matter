function thisrender(h, hFig, pos)
%RENDER Render the SPTool options frame.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:27:53 $

if nargin < 3 , pos =[]; end
if nargin < 2 , hFig = gcf; end

% Store the figure handle
set(h,'figureHandle',hFig);

% Get the default background color
bgc  = get(0,'defaultuicontrolbackgroundcolor');
hndls = get(h, 'handles');
enabstate = get(h, 'Enable');
visstate = get(h, 'Visible');

% Render frame
hndls.framewlabel_hndl = render_frame(h, bgc, pos, visstate);

% Store the HG object handles
set(h, 'Handles', hndls)

hlnv = getcomponent(h, 'siggui.labelsandvalues');

% Determine positions for frame, labels, and UIs.
if isempty(pos),
    pos = get(hndls.framewlabel_hndl(1),'Position');
end
sz = xp_gui_sizes(h);
lnvPos = [pos(1)+sz.lfs pos(2)+sz.vfus pos(3)-(2*sz.hfus) pos(4)-(2.5*sz.vfus)];
render(hlnv, hFig, lnvPos,largestuiwidth(get(hlnv,'Labels')));

%---------------------------------------------------------------------------
function hndl = render_frame(h, bgc, pos, visstate)
%RENDER_FRAME Render the SPTool Options frame.

hFig = get(h, 'FigureHandle');
if isempty(pos),
    sz = xp_gui_sizes(h);
    pos = sz.VarNamesPos;
end

hndl = framewlabel(hFig, pos, ...
    'SPTool Options', 'sptooloptsframe', bgc, visstate);

% [EOF]
