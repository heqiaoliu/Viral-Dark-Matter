function specs = thisgetspecs(this)
%THISGETSPECS   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/04/04 17:00:40 $

specs.Fpass1 = this.Fcutoff1;
specs.Fstop1 = this.Fcutoff1;
specs.Fstop2 = this.Fcutoff2;
specs.Fpass2 = this.Fcutoff2;
specs.Apass1 = NaN;
specs.Astop  = NaN;
specs.Apass2 = NaN;

% [EOF]
