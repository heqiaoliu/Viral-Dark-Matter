function thisrender(this, varargin)
%THISRENDER Render the destination options frame.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2004/04/13 00:27:49 $

pos = parserenderinputs(this, varargin{:});

sz = xp_gui_sizes(this);

if isprop(this,'ExportAs'),
    % Render the "Export As" frame above the destination options frame
    render_exportas(this,pos);
end

% Call super class thisrender method.
if isempty(pos),
    pos = sz.VarNamesPos;
elseif isprop(this,'ExportAs')
    % Position was specific, adjust for the "Export As" frame 
    pos = [pos(1) pos(2) pos(3) pos(4)-(sz.XpAsFrpos(4)+sz.vffs)];
end

abstractxdwvars_thisrender(this,pos);

hlnv = getcomponent(this, 'siggui.labelsandvalues');

if ~isrendered(hlnv),
    
    hFig = get(this,'FigureHandle');
    sz   = xp_gui_sizes(this);
    
    % Define the position for the labelsandvalues object (taking into account
    % the "Overwrite Variables" checkbox
    ypos = pos(2)+sz.vfus*1.9;
    render(hlnv,this.FigureHandle, ...
        [pos(1)+sz.lfs ypos pos(3)-(2*sz.hfus) pos(4)-(4*sz.vfus)], ...
        largestuiwidth(get(hlnv,'Labels')));
    set(hlnv, 'Visible', get(this, 'Visible'));
end

% % Add contextsensitive help
% cshelpcontextmenu(this, 'fdatool_Export2SPToolOpts');

% [EOF]
