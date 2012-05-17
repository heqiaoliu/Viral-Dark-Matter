function visible_listener(this, eventData)
%VISIBLE_LISTENER Listener to the visible property of the design panel

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.5 $  $Date: 2004/04/13 00:22:33 $

visState = get(this, 'Visible');

set([getcomponent(this, '-class', 'siggui.selector', 'Name', 'Response Type') ...
    getcomponent(this, '-class', 'siggui.selector', 'Name', 'Design Method') ...
        this.ActiveComponents], 'Visible', visState);

if isempty(this.CurrentDesignMethod), set(this.Frames, 'Visible', visState); end
        
set(this.Handles.design, 'Visible', visState)

listeners(this, eventData, 'staticresponse_listener'); 

% [EOF]
