function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:03:07 $

specs.Fpass = 2*this.BT/this.SamplesPerSymbol;
specs.Fstop = NaN;
specs.Apass = NaN;
specs.Astop = NaN;

% [EOF]
