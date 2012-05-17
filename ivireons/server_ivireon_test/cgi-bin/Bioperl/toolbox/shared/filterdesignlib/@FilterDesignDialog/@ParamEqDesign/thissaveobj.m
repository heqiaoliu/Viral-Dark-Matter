function s = thissaveobj(this, s)
%THISSAVEOBJ Save this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/04/09 18:57:22 $

s.F0     = this.F0;
s.BW     = this.BW;
s.BWpass = this.BWpass;
s.BWstop = this.BWstop;
s.Flow   = this.Flow;
s.Fhigh  = this.Fhigh;
s.Gref   = this.Gref;
s.G0     = this.G0;
s.GBW    = this.GBW;
s.Gpass  = this.Gpass;
s.Gstop  = this.Gstop;

s.FrequencyConstraints = this.FrequencyConstraints;
s.MagnitudeConstraints = this.MagnitudeConstraints;

% [EOF]
