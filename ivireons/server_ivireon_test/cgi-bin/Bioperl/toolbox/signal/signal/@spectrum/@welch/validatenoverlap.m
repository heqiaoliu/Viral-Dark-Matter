function  validatenoverlap(this, NOverlap,N)
%VALIDATENOVERLAP Validate the noverlap

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:45:23 $

if NOverlap>N-1,
    error(generatemsgid('InvalidOverlapPercent'), ...
        ['The percentage of overlap between each segment must be less than ', ...
        num2str(100*(N-1)/N), ' with segments of length ',num2str(N),'.']);
end

% [EOF]
