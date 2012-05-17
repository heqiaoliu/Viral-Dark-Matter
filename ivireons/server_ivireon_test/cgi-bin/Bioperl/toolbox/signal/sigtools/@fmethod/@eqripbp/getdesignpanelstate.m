function s = getdesignpanelstate(this)
%GETDESIGNPANELSTATE   Get the designpanelstate.

%   Author(s): J. Schickler
%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:43:33 $

s = eqrip_getdesignpanelstate(this);

s.Components{2}.Tag    = 'fdadesignpanel.bpweight';
s.Components{2}.Wstop1 = sprintf('%g', this.Wstop1);
s.Components{2}.Wpass  = sprintf('%g', this.Wpass);
s.Components{2}.Wstop2 = sprintf('%g', this.Wstop2);

% [EOF]
