function thisloadobj(this, s)
%THISLOADOBJ Load this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/04/09 18:57:21 $

this.F0     = s.F0;
this.BW     = s.BW;
this.BWpass = s.BWpass;
this.BWstop = s.BWstop;
this.Flow   = s.Flow;
this.Fhigh  = s.Fhigh;
this.Gref   = s.Gref;
this.G0     = s.G0;
this.GBW    = s.GBW;
this.Gpass  = s.Gpass;
this.Gstop  = s.Gstop;

if isfield(s, 'FrequencyConstraints')
    this.FrequencyConstraints = s.FrequencyConstraints;
    this.MagnitudeConstraints = s.MagnitudeConstraints;
end

% [EOF]
