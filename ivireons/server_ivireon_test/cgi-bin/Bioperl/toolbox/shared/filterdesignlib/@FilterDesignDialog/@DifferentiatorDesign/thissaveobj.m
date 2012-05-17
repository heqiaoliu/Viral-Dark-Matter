function s = thissaveobj(this, s)
%THISSAVEOBJ   Save this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:22:45 $

s.Fpass = this.Fpass;
s.Fstop = this.Fstop;
s.Apass = this.Apass;
s.Astop = this.Astop;
s.FrequencyConstraints = this.FrequencyConstraints;
s.MagnitudeConstraints = this.MagnitudeConstraints;

% [EOF]
