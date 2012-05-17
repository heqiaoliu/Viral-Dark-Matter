function thisloadobj(this, s)
%THISLOADOBJ   Load this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:24:25 $

this.TransitionWidth      = s.TransitionWidth;
this.Astop                = s.Astop;
this.Band                 = s.Band;
this.FrequencyConstraints = s.FrequencyConstraints;
this.MagnitudeConstraints = s.MagnitudeConstraints;

% [EOF]
