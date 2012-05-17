function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:29:42 $


specs.Fpass1 = this.F3dB1;
specs.Fstop1 = this.F3dB1;
specs.Fstop2 = this.F3dB2;
specs.Fpass2 = this.F3dB2;
specs.Apass1 = this.Apass;
specs.Astop  = this.Astop;
specs.Apass2 = this.Apass;

% [EOF]
