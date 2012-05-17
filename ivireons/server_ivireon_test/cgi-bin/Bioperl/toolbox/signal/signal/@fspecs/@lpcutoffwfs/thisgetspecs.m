function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:34:00 $

specs.Fpass = this.F3dB;
specs.Fstop = this.Fstop;
specs.Apass = NaN;
specs.Astop = NaN;

% [EOF]
