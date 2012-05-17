function thisloadobj(this, s)
%THISLOADOBJ   Load this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:23:26 $

this.Fstop = s.Fstop;
this.F6dB  = s.F6dB;
this.F3dB  = s.F3dB;
this.Fpass = s.Fpass;
this.Astop = s.Astop;
this.Apass = s.Apass;
this.FrequencyConstraints = s.FrequencyConstraints;
this.MagnitudeConstraints = s.MagnitudeConstraints;

% [EOF]
