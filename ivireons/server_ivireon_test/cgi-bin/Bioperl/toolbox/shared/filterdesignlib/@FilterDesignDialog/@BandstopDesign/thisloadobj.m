function thisloadobj(this, s)
%THISLOADOBJ   Load this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:21:46 $

this.Fpass1 = s.Fpass1;
this.F3dB1  = s.F3dB1;
this.F6dB1  = s.F6dB1;
this.Fstop1 = s.Fstop1;
this.Fstop2 = s.Fstop2;
this.F6dB2  = s.F6dB2;
this.F3dB2  = s.F3dB2;
this.Fpass2 = s.Fpass2;
this.BWpass = s.BWpass;
this.BWstop = s.BWstop;
this.Apass1 = s.Apass1;
this.Astop  = s.Astop;
this.Apass2 = s.Apass2;
this.FrequencyConstraints = s.FrequencyConstraints;
this.MagnitudeConstraints = s.MagnitudeConstraints;

% [EOF]
