function measurements = measure(this, hd, hm)
%MEASURE   Get the measurements.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:34:05 $

measurements = get_lp_measurements(this, hd, hm, [], this.Fpass, this.Fstop, [], []);


% [EOF]
