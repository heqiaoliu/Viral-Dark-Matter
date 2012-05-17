function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:02:18 $

specs.Fpass = (1-this.RolloffFactor)/this.SamplesPerSymbol;
specs.Fstop = (1+this.RolloffFactor)/this.SamplesPerSymbol;
specs.Apass = NaN;
specs.Astop = NaN;

% [EOF]
