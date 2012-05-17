function [y,z] = linearfdfilter(this,x,d,z)
%LINEARFDFILTER   

%   Author(s): V. Pellissier
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/17 22:44:00 $

x = quantizeinput(this,x);
y = quantizeinput(this,zeros(size(x)));
nx = size(x,1);
for i=1:nx,
    y(i,:) = d*z(1,:)+(1-d)*x(i,:);
    z(1,:) = x(i,:);
end


% [EOF]
