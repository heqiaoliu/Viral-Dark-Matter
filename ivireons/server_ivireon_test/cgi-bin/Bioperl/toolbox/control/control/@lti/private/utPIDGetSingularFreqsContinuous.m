function w = utPIDGetSingularFreqsContinuous(Type,rFunc,rC,wC,FlowDirection,NumOfIntersection,SignAtInf,rStar)
% Singular frequency based P/PI/PID Tuning sub-routine (Continuous).
%
% This function first computes singular frequencies determined by the
% intersections between a horizontal line r* and the r(w) curve.
%
% Input arguments
%   rFunc:              r(s) curve
%   rC:                 Critical r values
%   wC:                 Critical frequencies
%   FlowDirection:      indicating monotonically increasing/decreasing of a r(w) curve segment
%   NumOfIntersection:  expected number of intersections for a given r* value
%   SignAtInf:          1: approach +inf, -1: approach -inf, 0: converge to a finite value
%   rStar:              rStar* line
%
% Output arguments
%   w:                  frequencies at the intersections

%   Author(s): Rong Chen
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $ $Date: 2008/12/04 22:21:12 $

% if no intersection (sigular frequency) exists between (0,inf), exit
if NumOfIntersection==0
    w = [];
% else, initialize w with nans
else
    w = nan(NumOfIntersection,1);
    % find all the intersections between line rStar and curve rStar(w)
    ctW = 1;
    % deal with main intersections
    for ct = 1:length(wC)-1-(SignAtInf==0)
        % when rStar is between two successive rC values, there is an intersection
        if (rStar>rC(ct) && rStar<rC(ct+1)) || (rStar<rC(ct) && rStar>rC(ct+1))
            % when flow direction is +1, the curve is monotonically increasing
            if FlowDirection(ctW+1)==1
                w(ctW) = utPIDFindIntersectionNewton(Type,rFunc,wC(ct),wC(ct+1),rC(ct),rC(ct+1),rStar,'continuous');
            % when flow direction is -1, the curve is monotonically decreasing
            else
                w(ctW) = utPIDFindIntersectionNewton(Type,rFunc,wC(ct+1),wC(ct),rC(ct+1),rC(ct),rStar,'continuous');
            end
            % update counter
            ctW = ctW+1;
        end
    end
    % deal with the intersection between the last non-inf wC and w=inf
    % when w still contains nan value, there will be an intersection 
    if any(isnan(w))
        % when rStar(inf) is finite, we define LB as wC(end-1)
        if SignAtInf == 0
            wLeft = wC(end-1);
            KLeft = rC(end-1);
        % when rStar(inf) is infinite, we define LB as wC(end)
        else
            wLeft = wC(end);
            KLeft = rC(end);
        end
        % loop through to find a valid UB value since it can not be inf
        wRight = max(1,2*wLeft);
        if strcmp(Type,'Kp')
            KRight = real(evalfr(rFunc,1i*wRight));
        else
            KRight = imag(evalfr(rFunc,1i*wRight))*wRight;
        end
        % branch on the flow direction 
        if FlowDirection(ctW+1)==1
            % curve is monotonically increasing
            while KRight<=rStar
                wRight = wRight*2;
                if strcmp(Type,'Kp')
                    newKRight = real(evalfr(rFunc,1i*wRight));
                else
                    newKRight = imag(evalfr(rFunc,1i*wRight))*wRight;
                end
                if newKRight<=KRight
                    w(end) = -1;
                    return
                else
                    KRight = newKRight;
                end
            end
            % find the last w
            w(end) = utPIDFindIntersectionNewton(Type,rFunc,wLeft,wRight,KLeft,KRight,rStar,'continuous');
        else 
            % curve is monotonically decreasing
            while KRight>=rStar
                wRight = wRight*2;
                if strcmp(Type,'Kp')
                    newKRight = real(evalfr(rFunc,1i*wRight));
                else
                    newKRight = imag(evalfr(rFunc,1i*wRight))*wRight;
                end
                if newKRight>=KRight
                    w(end) = -1;
                    return
                else
                    KRight = newKRight;
                end
            end
            % find the last w
            w(end) = utPIDFindIntersectionNewton(Type,rFunc,wRight,wLeft,KRight,KLeft,rStar,'continuous');
        end
    end
end
