function specs = thisgetspecs(this)
%THISGETSPECS   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:32:01 $

specs.Fpass = this.F3dB;
specs.Fstop = this.F3dB;
specs.Apass = this.Apass;
specs.Astop = this.Astop;

% [EOF]
