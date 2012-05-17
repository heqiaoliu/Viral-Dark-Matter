function NOverlap = overlapsamples(this)
%OVERLAPSAMPLES Return the number of overlap samples.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:45:21 $

N = this.SegmentLength;
NOverlap = ceil((this.OverlapPercent/100) * N);

validatenoverlap(this,NOverlap,N);

% [EOF]
