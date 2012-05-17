function updatetitle(hObj)
%UPDATETITLE Update the title on the axes

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/11/19 21:46:35 $

ht = title(getbottomaxes(hObj), xlate(get(hObj, 'Name')));

if strcmpi(get(hObj, 'Visible'), 'on'),
    titleVis = get(hObj, 'Title');
else
    titleVis = 'off';
end
set(ht, 'visible', titleVis);

% [EOF]
