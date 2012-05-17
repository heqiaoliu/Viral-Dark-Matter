function enable_listener(hObj, eventData)
%ENABLE_LISTENER Listener to the enable property of FVTool

% Author(s): J. Schickler
% Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.2 $ $Date: 2002/04/14 23:28:09 $

siggui_enable_listener(hObj);

enabState = get(hObj,'Enable');

if strcmpi(enabState,'on'),
    lcolor = [0 0 0];
    bcolor = [1 1 1];
else
    bcolor = get(0,'DefaultUicontrolBackgroundColor');
    lcolor = [.4 .4 .4];
end

h = get(hObj, 'Handles');

set(h.axes,'Color',bcolor);
set(h.axes,'XColor',lcolor);
set(h.axes,'YColor',lcolor);

hText = findall(h.axes,'type','text');
hLines = findall(h.axes,'type','line');
set([hLines; hText],'color',lcolor);

hPatch = findall(h.axes,'type','patch');
set(hPatch,'EdgeColor',lcolor);


% [EOF]
