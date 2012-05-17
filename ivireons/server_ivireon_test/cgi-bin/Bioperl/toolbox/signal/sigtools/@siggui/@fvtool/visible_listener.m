function visible_listener(this, eventData)
%VISIBLE_LISTENER Listener to the visible property of FVTool

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/13 00:24:06 $

h        = get(this,'Handles');
visState = get(this,'Visible');

set(h.menu.analysis,'Visible',visState);
set(convert2vector(h.toolbar),'Visible',visState);
set(this.CurrentAnalysis, 'Visible', visState);

if strcmpi(visState, 'Off'),
    hdlg = get(this, 'Parameterdlg');
    if ~isempty(hdlg),
        cancel(hdlg);
    end
end

% [EOF]
