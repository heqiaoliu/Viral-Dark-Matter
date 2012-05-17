function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:32:07 $

specs.Fstop = this.F3dB;
specs.Fpass = this.F3dB;
specs.Astop = this.Astop;
specs.Apass = NaN;

% [EOF]
