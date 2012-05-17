function specs = thisgetspecs(this)
%THISGETSPECS   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/04/04 17:00:56 $

specs.Fpass1 = this.Fpass1;
specs.Fstop1 = this.Fstop1;
specs.Fstop2 = this.Fstop2;
specs.Fpass2 = this.Fpass2;
specs.Apass1 = this.Apass;
specs.Astop  = NaN;
specs.Apass2 = this.Apass;

% [EOF]
