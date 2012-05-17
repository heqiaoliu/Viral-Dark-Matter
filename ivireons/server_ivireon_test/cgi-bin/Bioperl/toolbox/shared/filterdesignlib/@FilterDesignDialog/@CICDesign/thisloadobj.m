function thisloadobj(this, s)
%THISLOADOBJ   Load this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:22:15 $

this.DifferentialDelay = s.DifferentialDelay;
this.Fpass             = s.Fpass;
this.Astop             = s.Astop;

% [EOF]
