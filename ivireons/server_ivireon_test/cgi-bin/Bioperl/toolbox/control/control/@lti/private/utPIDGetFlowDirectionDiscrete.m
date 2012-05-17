function [FlowDirections,NumOfIntersections]= utPIDGetFlowDirectionDiscrete(rGrid,rC,SignAtPI)
% Singular frequency based P/PI/PID/PIDF Tuning sub-routine (Discrete).
%
% This function returns flow directions for singular lines in each r1/r0 interval
%
% Input arguments
%   rGrid:      grid points
%   rC:         critical r1/r0 values
%   SignAtPI:   the sign of r(PI)
%
% Output arguments
%   - FlowDirections
%       each cell contains a vector of interlacing {1, -1} values that
%       represent the flow direction inside a particular r1/r0 interval.
%       The first flow direction is at alpha=0, defined as the sign of
%       r1(0)-r1* (or r0(0)-r0*)
%   - NumOfIntersections
%       the number of intersections between line r* and curve r(w)
%       inside a particular interval. 

%   Author(s): Rong Chen
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2008/12/04 22:21:07 $

%% ------------------------------------------------------------------------
sw = warning('off'); [lw,lwid] = lastwarn; %#ok<*WNOFF>
% pick up the middle point at each r interval
rVal = rGrid(1:end-1)+diff(rGrid)/2;
% initialize outputs
FlowDirections = cell(length(rVal),1);
NumOfIntersections = zeros(length(rVal),1);
% for each given KVal, calculate flow direction
for ct = 1:length(rVal)
    % counter the number of intersections
    for i = 1:length(rC)-1
        if (rVal(ct)>rC(i) && rVal(ct)<rC(i+1)) || (rVal(ct)<rC(i) && rVal(ct)>rC(i+1))
            NumOfIntersections(ct) = NumOfIntersections(ct)+1;
        end
    end
    % deal with w=inf case
    if (SignAtPI>0 && rVal(ct)>rC(end)) || (SignAtPI<0 && rVal(ct)<rC(end))
        NumOfIntersections(ct) = NumOfIntersections(ct)+1;
    end
    % get signs for all the intersections
    sign0 = sign(rC(1)-rVal(ct));
    signs = ones(NumOfIntersections(ct),1)*sign0;
    signs(1:2:end)=-sign0;
    % form flow directions
    if SignAtPI==0
        FlowDirections(ct) = {[sign0;signs;sign(mod(NumOfIntersections(ct),2)-0.5)*sign0]};
    else
        FlowDirections(ct) = {[sign0;signs]};
    end
end
% reset warning
warning(sw); lastwarn(lw,lwid);
