function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:33:54 $

specs.Fpass = this.Fpass;
specs.Fstop = this.F3dB;
specs.Apass = NaN;
specs.Astop = NaN;

% [EOF]
