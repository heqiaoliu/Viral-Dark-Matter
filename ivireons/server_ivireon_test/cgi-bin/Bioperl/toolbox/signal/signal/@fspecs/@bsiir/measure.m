function measurements = measure(this, hd, hm)
%MEASURE   Get the measurements.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:30:06 $

measurements = get_bs_measurements(this, hd, hm, [], [], ...
    this.Fpass1, this.Fstop1, this.Fstop2, this.Fpass2, [], [], []);

% [EOF]


