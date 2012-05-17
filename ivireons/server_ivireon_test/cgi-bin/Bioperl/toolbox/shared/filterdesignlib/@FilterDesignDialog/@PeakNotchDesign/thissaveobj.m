function s = thissaveobj(this, s)
%THISSAVEOBJ Save this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/09/23 14:04:37 $

s.ResponseType = this.ResponseType;
s.F0    = this.F0;
s.Q     = this.Q;
s.BW    = this.BW;
s.Apass = this.Apass;
s.Astop = this.Astop;
s.FrequencyConstraints = this.FrequencyConstraints;
s.MagnitudeConstraints = this.MagnitudeConstraints;

% [EOF]
