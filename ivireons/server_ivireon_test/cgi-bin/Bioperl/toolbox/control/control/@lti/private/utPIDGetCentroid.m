function [centerX centerY] = utPIDGetCentroid(Vertices)
% Singular frequency based P/PI/PID/PIDF Tuning sub-routine.
%
% This function calculates centroid (center of mass) of a polygon
% X = sum ((y(i) - y(i+1)) (x(i)2 + x(i)x(i+1) + x(i+1)2)/6A) 
% Y = sum ((x(i+1) - x(i)) (y(i)2 + y(i)y(i+1) + y(i+1)2)/6A)
% where A = sum (x(i)*y(i+1)-x(i+1)*y(i)) / 2 
%

%   Author(s): Rong Chen
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:21:59 $

area = 0.0;
centroid = [0.0 0.0];
n = size(Vertices,1);
for i = 1 : n
    if ( i < n )
        ip1 = i + 1;
    else
        ip1 = 1;
    end
    temp = Vertices(i,1) * Vertices(ip1,2) - Vertices(ip1,1) * Vertices(i,2);
    area = area + temp;
    centroid = centroid + ( Vertices(ip1,:) + Vertices(i,:) ) * temp;
end
area = area / 2.0;
if ( area == 0.0 )
    centroid = [sum(Vertices(:,:))/n sum(Vertices(:,:))/n];
else
    centroid = centroid / ( 6.0 * area );
end
centerX = centroid(1);
centerY = centroid(2);
