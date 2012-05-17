function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:27:04 $

specs.Fpass = this.Flow;
specs.Fstop = this.Fhigh;
specs.Apass = NaN;
specs.Astop = NaN;

% [EOF]
