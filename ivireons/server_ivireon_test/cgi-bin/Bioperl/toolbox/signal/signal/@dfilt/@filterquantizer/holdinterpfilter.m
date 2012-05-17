function y = holdinterpfilter(this,L,x,ny,nchans)
%HOLDINTERPFILTER   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/11/18 14:24:14 $

% Quantize input
x = quantizeinput(this,x);
y = zeros(ny,nchans);
y = quantizeinput(this,y);

for i=1:nchans,
    xi = x(:,i);
    y(:,i) = reshape(xi(:,ones(L,1)).',ny,1);
end


% [EOF]
