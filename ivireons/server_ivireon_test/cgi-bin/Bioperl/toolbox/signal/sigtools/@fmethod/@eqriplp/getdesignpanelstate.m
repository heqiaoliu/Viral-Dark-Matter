function s = getdesignpanelstate(this)
%GETDESIGNPANELSTATE   Get the designpanelstate.

%   Author(s): J. Schickler
%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:44:10 $

s = eqrip_getdesignpanelstate(this);

s.Components{2}.Tag   = 'fdadesignpanel.lpweight';
s.Components{2}.Wpass = sprintf('%g', this.Wpass);
s.Components{2}.Wstop = sprintf('%g', this.Wstop);

% [EOF]
