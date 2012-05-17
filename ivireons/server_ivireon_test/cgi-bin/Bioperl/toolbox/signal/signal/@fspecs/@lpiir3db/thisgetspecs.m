function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs  - used in FVTOOL for drawing the mask.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/21 16:30:52 $

specs.Fpass = this.F3dB;
specs.Fstop = this.F3dB;
specs.Apass = NaN;
specs.Astop = NaN;

% [EOF]
