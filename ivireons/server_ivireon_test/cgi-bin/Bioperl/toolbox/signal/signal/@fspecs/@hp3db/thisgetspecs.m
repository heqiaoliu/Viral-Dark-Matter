function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:31:44 $

specs.Fstop = this.F3dB;
specs.Fpass = this.F3dB;
specs.Astop = NaN;
specs.Apass = NaN;

% [EOF]
