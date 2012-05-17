function s = eqrip_getdesignpanelstate(this)
%EQRIP_GETDESIGNPANELSTATE   

%   Author(s): J. Schickler
%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:42:41 $

s.DesignMethod                = 'filtdes.remez';
s.Components{1}.Tag           = 'siggui.remezoptionsframe';
s.Components{1}.DensityFactor = sprintf('%g', this.DensityFactor);

% [EOF]
