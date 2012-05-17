function thisrender(this, varargin)
%THISRENDER Render the destination options frame.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2004/04/13 00:27:59 $

pos  = parserenderinputs(this, varargin{:});
sz   = xp_gui_sizes(this);
h    = get(this,'Handles');
hFig = get(this,'FigureHandle');
cbs  = callbacks(this);

if isprop(this, 'ExportAs') && isdynpropenab(this,'ExportAs'),
    % Render the "Export As" frame above the destination options frame
    render_exportas(this,pos);
elseif ishandlefield(this, 'xpaspopup'),
    delete([h.xpaspopup h.xpasfr]);
end

% Call super class thisrender method.
if isempty(pos),
    pos = sz.VarNamesPos;
elseif isprop(this, 'ExportAs') && isdynpropenab(this,'ExportAs')
    % Position was specific, adjust for the "Export As" frame 
    pos = [pos(1) pos(2) pos(3) pos(4)-(sz.XpAsFrpos(4)+sz.vffs)];
end
abstractxdwvars_thisrender(this,pos);
h    = get(this,'Handles');

sz.checkbox = [pos(1)+sz.hfus pos(2)+sz.vfus pos(3)-sz.hfus*2 sz.uh];

if ishandlefield(this, 'overwrite'),
    setpixelpos(this, h.overwrite, sz.checkbox);
else
    h.overwrite = uicontrol(hFig, ...
        'Position', sz.checkbox, ...
        'Style', 'Check', ...
        'Tag', 'export_checkbox', ...
        'Visible', 'Off', ...
        'Callback', {cbs.checkbox, this}, ...
        'String','Overwrite Variables');
    set(this,'Handles',h);
end

hlnv = getcomponent(this, 'siggui.labelsandvalues');
if ~isrendered(hlnv),
    
    hFig = get(this,'FigureHandle');
    sz   = xp_gui_sizes(this);
    
    % Define the position for the labelsandvalues object (taking into account
    % the "Overwrite Variables" checkbox
    ypos = pos(2)+(2*sz.vfus)+sz.uh;
    info = exportinfo(this.Data);
    if isfield(info, 'exportas'),
        width = largestuiwidth([get(hlnv, 'Labels'); info.variablelabel(:); info.exportas.objectvariablelabel(:)]);
    else
        width = largestuiwidth([get(hlnv, 'Labels'); info.variablelabel(:);]);
    end
    render(hlnv,hFig, ...
        [pos(1)+sz.lfs ypos pos(3)-(2*sz.hfus) pos(4)-(4*sz.vfus+sz.uh)], ...
        width);
    set(hlnv, 'Visible', get(this, 'Visible'));
end

l = handle.listener(this, this.findprop('OverWrite'), 'PropertyPostSet', @prop_listener);
set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', union(l, this.WhenRenderedListeners));

% % Add contextsensitive help
% cshelpcontextmenu(this, 'fdatool_Export2SPToolOpts');

% [EOF]
