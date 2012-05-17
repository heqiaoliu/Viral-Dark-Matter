function pos = renderlabelsnvalues(hObj, pos)
%RENDERLABELSNVALUES

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:22:02 $

sz = gui_sizes(hObj);

str = 'Constrain';
width = largestuiwidth({str});

pos = [pos(1)+sz.hfus pos(2) pos(3)-sz.hfus-width pos(4)-sz.uh-sz.vfus-4*sz.uuvs];

% Get the handle to the LabelsAndValues class
lvh = getcomponent(hObj, 'siggui.labelsandvalues');

hFig = get(hObj, 'FigureHandle');

% Render the LabelsAndValues class
render(lvh, hFig, pos);

n = 4;

skip = (pos(4)-n*sz.uh-n*sz.pixf)/(n-1);

h = get(hObj, 'Handles');

pos = [pos(1)+pos(3)+(width-sz.uh)/2 pos(2)-2*sz.vfus-skip-(n+3)*sz.pixf sz.uh sz.uh];
for indx = n:-1:1
    pos(2) = pos(2)+skip+sz.uh+sz.pixf;
    h.checkbox(indx) = uicontrol(hFig, ...
        'Position', pos, ...
        'Style', 'Checkbox', ...
        'Visible', 'Off', ...
        'Callback', {@lclcheckbox_cb, hObj, indx}, ...
        'Tag', sprintf('cmagspecs_checkbox%d', indx));
end

pos = [pos(1)-sz.pixf-(width-sz.uh)/2 pos(2)+skip width sz.uh];

h.clbl = uicontrol(hFig, ...
    'Visible', 'Off', ...
    'Style', 'Text', ...
    'Position', pos, ...
    'HorizontalAlignment', 'Left', ...
    'String', str);

set(hObj, 'Handles', h);

wrl = get(hObj, 'WhenRenderedListeners');

wrl = [wrl ...
        handle.listener(hObj, hObj.findprop('ConstrainedBands'), 'PropertyPostSet', ...
        @constrainedbands_listener) ...
        handle.listener(hObj, hObj.findprop('Labels'), 'PropertyPostSet', ...
        @labels_listener) ...
    ];

set(wrl, 'CallbackTarget', hObj);
set(hObj, 'WhenRenderedListeners', wrl);
constrainedbands_listener(hObj);
labels_listener(hObj);

% -------------------------------------------------
function lclcheckbox_cb(hcbo, eventStruct, hObj, indx)

cb = get(hObj, 'ConstrainedBands');

if get(hcbo, 'Value') > eps
    set(hObj, 'ConstrainedBands', union(cb, indx));
else
    set(hObj, 'ConstrainedBands', setdiff(cb, indx));
end

send(hObj, 'UserModifiedSpecs', handle.EventData(hObj, 'UserModifiedSpecs'));

% [EOF]
