function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/04/04 17:00:18 $

specs.Fstop1 = this.Fcutoff1;
specs.Fpass1 = this.Fcutoff1;
specs.Fpass2 = this.Fcutoff2;
specs.Fstop2 = this.Fcutoff2;
specs.Astop1 = NaN;
specs.Apass  = NaN;
specs.Astop2 = NaN;

% [EOF]
