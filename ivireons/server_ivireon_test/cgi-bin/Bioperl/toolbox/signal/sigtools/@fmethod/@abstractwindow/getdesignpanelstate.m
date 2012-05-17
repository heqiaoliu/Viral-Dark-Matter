function s = getdesignpanelstate(this)
%GETDESIGNPANELSTATE   Get the designpanelstate.

%   Author(s): J. Schickler
%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:43:17 $

s.DesignMethod  = 'filtdes.fir1';

s.Components{1}.Tag = 'siggui.firwinoptionsframe';
if this.ScalePassband
    s.Scale         = 'On';
else
    s.Scale         = 'Off';
end

% [EOF]
