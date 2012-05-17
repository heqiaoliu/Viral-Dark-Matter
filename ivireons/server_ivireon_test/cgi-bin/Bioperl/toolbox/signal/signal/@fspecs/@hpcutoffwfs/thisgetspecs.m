function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:32:26 $

specs.Fstop = this.Fstop;
specs.Fpass = this.F3dB;
specs.Astop = NaN;
specs.Apass = NaN;

% [EOF]
