function enable_listener(this, eventData)
%ENABLE_LISTENER   Listener to 'enable'.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $  $Date: 2004/04/13 00:30:27 $

sigcontainer_enable_listener(this, eventData);

updateaxes(this);

% -----------------------------------------------------
function updateaxes(this)

enabState = get(this, 'Enable');

if strcmpi(enabState,'on'),
    lcolor = [0 0 0];
    bcolor = [1 1 1];
else
    bcolor = get(0,'DefaultUicontrolBackgroundColor');
    lcolor = [.4 .4 .4];
end

h = get(this, 'Handles');

set(h.staticresp,'Color',bcolor);
set(h.staticresp,'XColor',lcolor);
set(h.staticresp,'YColor',lcolor);

hText = findall(h.staticresp,'type','text');
hLines = findall(h.staticresp,'type','line');
set([hLines; hText],'color',lcolor);

hPatch = findall(h.staticresp,'type','patch');
set(hPatch,'EdgeColor',lcolor);

% [EOF]
