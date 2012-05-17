function enable_listener(this, eventData)
%ENABLE_LISTENER Listener to 'enable'

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/08/22 20:33:17 $

enabState = this.Enable;

h = this.Handles;

set(h.errorstatus, 'Enable', enabState);

if ~isempty(this.ErrorStatus)
    enabState = 'off';
end

setenableprop([h.gain_lbl h.gain h.actionbtn h.coordinatemode_lbl h.coordinatemode ...
    h.real_lbl h.real h.imaginary_lbl h.imaginary h.currentsection_lbl ...
    h.currentsection h.conjugatemode h.announcenewspecs], enabState);

% [EOF]
