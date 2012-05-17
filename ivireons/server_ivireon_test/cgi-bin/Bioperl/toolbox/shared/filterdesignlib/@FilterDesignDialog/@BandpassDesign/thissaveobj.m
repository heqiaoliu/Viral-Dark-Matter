function s = thissaveobj(this, s)
%THISSAVEOBJ   Save this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:21:30 $

s.Fstop1 = this.Fstop1;
s.F6dB1  = this.F6dB1;
s.F3dB1  = this.F3dB1;
s.Fpass1 = this.Fpass1;
s.Fpass2 = this.Fpass2;
s.F3dB2  = this.F3dB2;
s.F6dB2  = this.F6dB2;
s.Fstop2 = this.Fstop2;
s.BWpass = this.BWpass;
s.BWstop = this.BWstop;
s.Astop1 = this.Astop1;
s.Apass  = this.Apass;
s.Astop2 = this.Astop2;
s.FrequencyConstraints = this.FrequencyConstraints;
s.MagnitudeConstraints = this.MagnitudeConstraints;

% [EOF]
