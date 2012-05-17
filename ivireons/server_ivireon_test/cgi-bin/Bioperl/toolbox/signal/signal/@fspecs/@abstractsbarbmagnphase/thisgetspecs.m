function specs = thisgetspecs(this)
%THISGETSPECS   Get the specs.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:27:36 $

specs.Frequencies = this.Frequencies;
specs.Magnitudes = abs(this.FreqResponse);
specs.Phases = angle(this.FreqResponse);


% [EOF]
