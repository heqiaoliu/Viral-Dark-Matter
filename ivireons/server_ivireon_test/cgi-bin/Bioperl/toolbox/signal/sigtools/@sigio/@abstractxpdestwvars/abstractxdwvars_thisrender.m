function abstractxdwvars_thisrender(this, pos)
%ABSTRACTXDWVARS_THISRENDER Render the destination options frame.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2004/04/13 00:27:16 $

if nargin < 2 , pos =[]; end

hFig = get(this,'FigureHandle');
bgc  = get(0,'defaultuicontrolbackgroundcolor');
hndls = get(this, 'handles');
enabstate = get(this, 'Enable');
visstate = get(this, 'Visible');

% Render frame
hFig = get(this, 'FigureHandle');

if isempty(pos),
    sz = xp_gui_sizes(this);
    pos = sz.VarNamesPos;
end

h = get(this, 'Handles');

if ishandlefield(this, 'framewlabel'),
    framewlabel(h.framewlabel, pos);
else
    h.framewlabel = framewlabel(hFig, pos, ...
        'Variable Names', 'varnames', bgc, visstate);
    
    % Store the HG object handles
    set(this, 'Handles', h)
end

% [EOF]
