function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:30:01 $

tw = (this.F3dB1-this.F3dB2-this.BWstop)/2;

specs.Fpass1 = this.F3dB1;
specs.Fstop1 = this.F3dB1+tw;
specs.Fstop2 = this.F3dB2-tw;
specs.Fpass2 = this.F3dB2;
specs.Apass1 = NaN;
specs.Astop  = NaN;
specs.Apass2 = NaN;

% [EOF]
