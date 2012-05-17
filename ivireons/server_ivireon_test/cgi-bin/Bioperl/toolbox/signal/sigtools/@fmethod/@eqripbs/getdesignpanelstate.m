function s = getdesignpanelstate(this)
%GETDESIGNPANELSTATE   Get the designpanelstate.

%   Author(s): J. Schickler
%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:43:37 $

s = eqrip_getdesignpanelstate(this);

s.Components{2}.Tag    = 'fdadesignpanel.hpweight';
s.Components{2}.Wpass1 = sprintf('%g', this.Wpass1);
s.Components{2}.Wstop  = sprintf('%g', this.Wstop);
s.Components{2}.Wpass2 = sprintf('%g', this.Wpass2);

% [EOF]
