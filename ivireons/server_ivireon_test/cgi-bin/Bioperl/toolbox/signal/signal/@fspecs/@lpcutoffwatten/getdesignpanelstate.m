function s = getdesignpanelstate(this)
%GETDESIGNPANELSTATE   Get the designpanelstate.

%   Author(s): J. Schickler
%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:33:42 $

s = aswofs_getdesignpanelstate(this);

s.Components{1}.Tag          = 'fdadesignpanel.freqfirceqrip';
s.Components{1}.freqSpecType = 'cutoff';
s.Components{1}.Fc           = sprintf('%g', this.Fcutoff);

s.Components{3}.Tag      = 'fdesignpanel.lpmag';
s.Components{3}.magUnits = 'dB';
s.Components{3}.Apass    = sprintf('%g', this.Apass);
s.Components{3}.Astop    = sprintf('%g', this.Astop);

% [EOF]
