function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/04/04 17:01:33 $

specs.Fstop = this.Fstop;
specs.Fpass = this.Fstop;
specs.Astop = this.Astop;
specs.Apass = NaN;

% [EOF]
