function [rGrid, GridPoints] = utPIDGetGrids(rCritical)
% Singular frequency based P/PI/PID/PIDF Tuning sub-routine.
%
% This function generates grid points for a range that covers critical r1
% values.  The total number of grid points is given as an input argument.

%   Author(s): Rong Chen
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:31:17 $

% total number of grid points on r axis
NumOfGridPoints = 50;
% sort critical r1
rC = sort(rCritical);
% make sure r1 is unique: |a-b|<=tol*(|a|+|b|)
if length(rC)>1
    absR1 = abs(rC);
    ind =[true;abs(diff(rC))>sqrt(eps)*(1+absR1(1:end-1)+absR1(2:end))];
    rC = rC(ind);
end
if abs(rC(1))>=0.1
    FirstValue = rC(1)-abs(rC(1))*10;        
else
    FirstValue = rC(1)-1;        
end
if abs(rC(end))>=0.1
    LastValue = rC(end)+abs(rC(end))*10;                
else
    LastValue = rC(end)+1;                
end

rGrid = [FirstValue;rC;LastValue];    

% Assume V is a vector of positive real numbers, we have Cover = b^(p:q)
% where
%   b is the basis, i.e. log10(Total number of grid points)
%   p is chosen so that b^p = Xmin = 1e-2 * min(V)
%   q is chosen so that b^p = Xmax = max(V)
% Such a cover amounts to varying rC by multiplicative increments of b, a
% reasonable way to cover the entire rC range.  If the number of grids
% inside an interval is smaller than NumOfGridPoints, extra grid points
% will be added. 

% find the cover for positive r1
r1 = rGrid(rGrid>0);
Xmin = 1e-2 * min(r1);
Xmax = max(abs(r1));
b = log10(NumOfGridPoints);
p = log10(Xmin)/log10(b);
q = log10(Xmax)/log10(b);
CoverPositive = b.^(p:(q-p)/NumOfGridPoints:q);
% find the cover for negative r1
r1 = fliplr(abs(rGrid(rGrid<0)));
Xmin = 1e-2 * min(r1);
Xmax = max(abs(r1));
b = log10(NumOfGridPoints);
p = log10(Xmin)/log10(b);
q = log10(Xmax)/log10(b);
CoverNegative = fliplr(-(b.^(p:(q-p)/NumOfGridPoints:q)));
% build cover
Cover = [CoverNegative CoverPositive];
 
% initialize GridPoints cell array
MinimumPoints = 10;
NumInterval = length(rGrid)-1;
GridPoints = cell(NumInterval,1);
% create r1 intervals from cover
for ct = 1:NumInterval
    Values = Cover((Cover>=rGrid(ct))&(Cover<=rGrid(ct+1)));
    if length(Values)<MinimumPoints
        % append extra grid points 
        if abs(rGrid(ct))<sqrt(eps) || abs(rGrid(ct+1))<sqrt(eps) || ...
                sign(rGrid(ct))~=sign(rGrid(ct+1)) || abs(log10(rGrid(ct+1)/rGrid(ct)))<2
            % use linear space
            Values = linspace(rGrid(ct),rGrid(ct+1),MinimumPoints+2);        
        else
            % use log space
            if sign(rGrid(ct))==1
                Values = logspace(log10(rGrid(ct)),log10(rGrid(ct+1)),MinimumPoints+2);
            else
                Values = -logspace(log10(-rGrid(ct)),log10(-rGrid(ct+1)),MinimumPoints+2);
            end
        end
        Values = Values(2:end-1);
    end
    GridPoints(ct) = {Values};
end
