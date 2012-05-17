function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/04/04 17:02:43 $

specs.Fpass = this.Fpass;
specs.Fstop = this.Fstop;
specs.Apass = this.Apass;
specs.Astop = NaN;

% [EOF]
