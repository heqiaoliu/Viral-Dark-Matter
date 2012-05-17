function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:31:54 $

specs.Fstop = this.F3db;
specs.Fpass = this.F3db;
specs.Astop = NaN;
specs.Apass = this.Apass;

% [EOF]
