function newselection_listener(this, eventData)
%NEWSELECTION_LISTENER   Listener to the NewSelection event.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/12/26 22:22:16 $

switch lower(this.ViewType)
    case 'userdefined'
        enab1 = this.Enable;
        enab2 = 'off';
    case 'cumulative'
        enab1 = 'off';
        enab2 = this.Enable;
    otherwise
        enab1 = 'off';
        enab2 = 'off';
end

setenableprop(this.Handles.custom, enab1);
setenableprop(this.Handles.secondaryscaling, enab2);
prop_listener(this, 'secondaryscaling');

% [EOF]
