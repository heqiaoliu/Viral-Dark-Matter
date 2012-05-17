function s = getdesignpanelstate(this)
%GETDESIGNPANELSTATE   Get the designpanelstate.

%   Author(s): J. Schickler
%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:29:13 $

s = aswofs_getdesignpanelstate(this);

s.Components{1}.Tag    = 'fdadesignpanel.bpfreqstop';
s.Components{1}.Fstop1 = sprintf('%g', this.Fstop1);
s.Components{1}.Fstop2 = sprintf('%g', this.Fstop2);

s.Components{3}.Tag      = 'fdadesignpanel.bpmagstop';
s.Components{3}.magUnits = 'dB';
s.Components{3}.Astop    = sprintf('%g', this.Astop);

% [EOF]
