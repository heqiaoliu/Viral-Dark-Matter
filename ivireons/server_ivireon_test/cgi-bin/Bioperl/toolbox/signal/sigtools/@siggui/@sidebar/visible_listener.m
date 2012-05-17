function visible_listener(this, eventData)
%VISIBLE_LISTENER Listener to the visible property

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.4 $  $Date: 2006/11/19 21:46:30 $

h = handles2vector(this);
visState = get(this, 'Visible');
set(h, 'Visible', visState);

hP = getpanelhandle(this, this.CurrentPanel);

if isstruct(hP),
    if strcmpi(visState, 'On'),
        feval(hP.show, this.FigureHandle);
    else
        feval(hP.hide, this.FigureHandle);
    end
else
    set(hP, 'Visible', visState);
end

% [EOF]
