function thisloadobj(this, s)
%THISLOADOBJ   Load this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:22:03 $

this.Fpass                = s.Fpass;
this.F6dB                 = s.F6dB;
this.Fstop                = s.Fstop;
this.Apass                = s.Apass;
this.Astop                = s.Astop;
this.NumberOfSections     = s.NumberOfSections;
this.DifferentialDelay    = s.DifferentialDelay;
this.FrequencyConstraints = s.FrequencyConstraints;
this.MagnitudeConstraints = s.MagnitudeConstraints;

% [EOF]
