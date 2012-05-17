function renderactionbtn(this, pos, str, method, varargin)
%RENDERACTIONBTN   Render the gui's action button
%   RENDERACTIONBTN(THIS, POS, STR, METHOD) Render the GUI's action
%   button to the center of POS with the label STR.  It will call the
%   method METHOD (string or function handle) via the method_cb of
%   SIGGUI_CBS.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/14 15:19:41 $

error(nargchk(4,5,nargin,'struct'));

sz  = gui_sizes(this);
cbs = siggui_cbs(this);

width = largestuiwidth({str}) + 20*sz.pixf;

if ischar(method), field = lower(method);
else,              field = lower(func2str(method)); end

tag = [get(classhandle(this), 'Name') '_' field];

h = get(this, 'Handles');

h.(field) = uicontrol(this.FigureHandle, ...
    'String', str, ...
    'Style', 'PushButton', ...
    'HorizontalAlignment', 'Center', ...
    'Tag', tag, ...
    'Visible', 'Off', ...
    'Position', [pos(1)+(pos(3)-width)/2 pos(2)+sz.vfus width sz.bh], ...
    'Callback', {cbs.method, this, method, varargin{:}});

set(this, 'Handles', h);

[cshtags, cshtool] = getcshtags(this);
if isfield(cshtags, field),
    cshelpcontextmenu(h.(field), cshtags.(field), cshtool);
end

% [EOF]
