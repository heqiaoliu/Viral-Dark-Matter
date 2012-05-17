function framewlabel(this, pos, lbl)
%FRAMEWLABEL   Create a framewlabel.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:19:38 $

error(nargchk(2,3,nargin,'struct'));

if nargin < 3,
    lbl = get(classhandle(this), 'Description');
end

h = get(this, 'Handles');

hnew = framewlabel(this.FigureHandle, pos, lbl, ...
    [strrep(class(this), '.', '_'), '_framewlabel'], ...
    get(0, 'defaultuicontrolbackgroundcolor'), 'Off');

if isfield(h, 'framewlabel')
    h.framewlabel = [h.framewlabel hnew];
else
    h.framewlabel = hnew;
end

[cshtags, cshtool] = getcshtags(this);
if isfield(cshtags, 'framewlabel'),
    cshelpcontextmenu(hnew, cshtags.framewlabel, cshtool);
end

set(this, 'Handles', h);

% [EOF]
