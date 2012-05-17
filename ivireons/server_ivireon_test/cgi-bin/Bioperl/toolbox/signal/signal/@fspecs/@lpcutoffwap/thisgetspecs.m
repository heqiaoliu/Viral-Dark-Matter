function specs = thisgetspecs(this)
%THISGETSPECS   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:33:28 $

specs.Fpass = this.F3dB;
specs.Fstop = this.F3dB;
specs.Apass = this.Apass;
specs.Astop = NaN;

% [EOF]
