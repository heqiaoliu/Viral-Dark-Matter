function s = getdesignpanelstate(this)
%GETDESIGNPANELSTATE   Get the designpanelstate.

%   Author(s): J. Schickler
%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:42:10 $

s.DesignMethod               = 'filtdes.cheby2';
s.Components{1}.Tag          = 'siggui.classiciiroptsframe';
s.Components{1}.MatchExactly = this.MatchExactly;

% [EOF]
