function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:29:26 $

specs.Fpass1 = this.F3db1;
specs.Fstop1 = this.F3db1;
specs.Fstop2 = this.F3db2;
specs.Fpass2 = this.F3db2;
specs.Apass1 = NaN;
specs.Astop  = NaN;
specs.Apass2 = NaN;

% [EOF]
