function [b, a] = thistf(this)
%THISTF   Return the transfer function.

%   Author(s): J. Schickler
%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 19:04:03 $

sv    = get(this, 'ScaleValues');
sosm  = get(this, 'SOSMatrix');
nsecs = size(sosm, 1);

% Pad the scale values with ones
sv = [sv;ones(nsecs+1-length(sv),1)];

% Embed gains in matrix
for n = 1:nsecs,
    sosm(n,1:3) = sosm(n,1:3)*sv(n);
end

b = 1; a = 1;
if nsecs>0,
    [b, a] = sos2tf(sosm,sv(nsecs+1));
end

% [EOF]
