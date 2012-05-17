function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/04/04 17:01:22 $

specs.Fstop = 1/2;
specs.Fpass = 1/2;
specs.Astop = this.Astop;
specs.Apass = NaN;

% [EOF]
