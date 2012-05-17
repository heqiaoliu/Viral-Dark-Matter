function destination_listener(this,eventData)
%DESTINATION_LISTENER

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2008/08/01 12:25:50 $

[oldWidth oldHeight] = destinationSize(this.Destination);
hnewd = eventData.NewValue;
[newWidth newHeight] = destinationSize(hnewd);

% Un-render the old destination object
unrender(this.destination);

if oldHeight ~= newHeight || oldWidth ~= newWidth
   resize(this, newWidth, newHeight);
end

% Render the new contained object
sz = export_gui_sizes(this, newWidth, newHeight);
% frPos = [sz.xpdestopts(1) sz.xpdestopts(2) sz.xpdestopts(3) newHght];
render(hnewd,this.FigureHandle,sz.xpdestopts);
set(hnewd,'Visible','On');

% Add contextsensitive help
cshelpcontextmenu(hnewd, this.CSHelpTag);

wrl = get(this, 'WhenRenderedListeners');
wrl(end-1) = handle.listener(hnewd, 'NewFrameHeight', @newheight_cb);
wrl(end) = handle.listener(hnewd, 'UserModifiedSpecs', @usermodifiedspecs_cb);
set(wrl, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', wrl);

% [EOF]
