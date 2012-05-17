function [FlowDirections NumOfIntersections]= utPIDGetFlowDirectionContinuous(KInterval,KC,SignAtInf)
% Singular frequency based P/PI/PID Tuning sub-routine (Continuous).
%
% This function returns flow directions for singular lines in each Kp or Ki
% interval.
%
% Input arguments
%   KInterval:  Kp or Ki intervals
%   KC:         critical Kp or Ki values
%   SignAtInf:  the sign of Kp(inf) or Ki(inf)
%
% Output arguments
%   - FlowDirections
%       each cell contains a vector of interlacing {1, -1} values that
%       represent the flow direction inside a particular Kp or Ki interval.
%       The first flow direction is at w=0, defined as the sign of
%       Kp(0)-Kp* or Ki(0)-Ki* where Kp* or Ki* are a sample in an interval
%   - NumOfIntersections
%       the number of intersections between line Kp*/Ki* and curve Kp(w)/Ki(w)
%       inside a particular interval. 

%   Author(s): Rong Chen
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2008/12/04 22:21:06 $

%% ------------------------------------------------------------------------
sw = warning('off'); [lw,lwid] = lastwarn; %#ok<*WNOFF>
% pick up the middle point at each r1/r0 interval
KVal = KInterval(1:end-1)+diff(KInterval)/2;
% initialize outputs
FlowDirections = cell(length(KVal),1);
NumOfIntersections = zeros(length(KVal),1);
% for each given KVal, calculate flow direction
for ct = 1:length(KVal)
    % counter the number of intersections
    for i = 1:length(KC)-1
        if (KVal(ct)>KC(i) && KVal(ct)<KC(i+1)) || (KVal(ct)<KC(i) && KVal(ct)>KC(i+1))
            NumOfIntersections(ct) = NumOfIntersections(ct)+1;
        end
    end
    % deal with w=inf case
    if (SignAtInf>0 && KVal(ct)>KC(end)) || (SignAtInf<0 && KVal(ct)<KC(end))
        NumOfIntersections(ct) = NumOfIntersections(ct)+1;
    end
    % get signs for all the intersections based on sign at w=0
    sign0 = sign(KC(1)-KVal(ct));
    signs = ones(NumOfIntersections(ct),1)*sign0;
    signs(1:2:end)=-sign0;
    % form flow directions
    if SignAtInf==0
        FlowDirections(ct) = {[sign0;signs;sign(mod(NumOfIntersections(ct),2)-0.5)*sign0]};
    else
        FlowDirections(ct) = {[sign0;signs]};
    end
end
% reset warning
warning(sw); lastwarn(lw,lwid);
