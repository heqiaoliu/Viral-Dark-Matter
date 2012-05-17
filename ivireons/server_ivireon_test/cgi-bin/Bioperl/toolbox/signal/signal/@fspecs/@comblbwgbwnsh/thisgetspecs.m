function specs = thisgetspecs(this)
%THISGETSPECS   

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:02:46 $

specs.CombType = this.CombType;
specs.NormalizedFrequency = this.NormalizedFrequency;
specs.Fs = this.Fs;
specs.FilterOrder = this.NumPeaksOrNotches;
specs.BW = this.BW;
specs.PeakNotchFrequencies = this.PeakNotchFrequencies;
% [EOF]
