function s = getdesignpanelstate(this)
%GETDESIGNPANELSTATE   Get the designpanelstate.

%   Author(s): J. Schickler
%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:29:27 $

s = aswofs_getdesignpanelstate(this);

s.Components{1}.Tag = 'fdadesignpanel.bsfreqcutoff';
s.Components{1}.Fc1 = sprintf('%g', this.Fcutoff1);
s.Components{1}.Fc2 = sprintf('%g', this.Fcutoff2);

% [EOF]
