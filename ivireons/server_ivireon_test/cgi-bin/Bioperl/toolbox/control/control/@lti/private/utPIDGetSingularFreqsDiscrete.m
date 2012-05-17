function alpha = utPIDGetSingularFreqsDiscrete(Type,rFunc,r1C,alphaC,FlowDirection,NumOfIntersection,SignAtPI,rStar)
% Singular frequency based P/PI/PID/PIDF Tuning sub-routine (Discrete).
%
% This function first computes singular frequencies determined by the
% intersections between a horizontal line r* and the r(z) curve.
%
% Input arguments
%   rFunc:              r(z) curve
%   rC:                 Critical r values
%   alphaC:             Critical frequencies
%   FlowDirection:      indicating monotonically increasing/decreasing of a r(z) curve segment
%   NumOfIntersection:  expected number of intersections for a given r* value
%   SignAtPI:           1: approach +inf, -1: approach -inf, 0: converge to a finite value
%   rStar:              r* line
%
% Output arguments
%   Alpha:              frequencies at the intersections

%   Author(s): Rong Chen
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $ $Date: 2008/12/04 22:21:13 $

% if no intersection (sigular frequency) exists between (0,PI), exit
if NumOfIntersection==0
    alpha = [];
else
    alpha = nan(NumOfIntersection,1);
    % find all the intersections between line rStar and curve r(z)
    ctR1 = 1;
    % deal with main intersections
    for ct = 1:length(alphaC)-1-(SignAtPI==0)
        % when rStar is between two successive critical rStar values, there is an intersection
        if (rStar>r1C(ct) && rStar<r1C(ct+1)) || (rStar<r1C(ct) && rStar>r1C(ct+1))
            % when flow direction is +1, the curve is monotonically increasing
            if FlowDirection(ctR1+1)==1
                alpha(ctR1) = utPIDFindIntersectionNewton(Type,rFunc,alphaC(ct),alphaC(ct+1),r1C(ct),r1C(ct+1),rStar,'discrete');
            % when flow direction is -1, the curve is monotonically decreasing
            else
                alpha(ctR1) = utPIDFindIntersectionNewton(Type,rFunc,alphaC(ct+1),alphaC(ct),r1C(ct+1),r1C(ct),rStar,'discrete');                
            end
            % update counter
            ctR1 = ctR1+1;
        end
    end
    % deal with the intersection between the last alpha and alpha=PI
    % when alpha still contains nan value, there will be an intersection 
    if any(isnan(alpha))
        % when rStar(inf) is finite, we define LB as wC(end-1)
        if SignAtPI == 0
            alphaLeft = alphaC(end-1);
            r1Left = r1C(end-1);
        else
            % define the lower boundary value (starting point)
            alphaLeft = alphaC(end);
            r1Left = r1C(end);
        end            
        % define the upper boundary value (ending point)
        alphaRight = (alphaLeft+pi)/2;
        r1Right = real(evalfr(rFunc,exp(alphaRight*1i)));
        % branch on the flow direction 
        if FlowDirection(ctR1+1)==1
            % curve is monotonically increasing
            while r1Right<=rStar
                alphaRight = (alphaRight+pi)/2;
                r1Right = real(evalfr(rFunc,exp(alphaRight*1i)));
            end
            % find alpha
            alpha(end) = utPIDFindIntersectionNewton(Type,rFunc,alphaLeft,alphaRight,r1Left,r1Right,rStar,'discrete');
        else 
            % decrease alphaRight until rStar is between riLeft abd r1Right
            while r1Right>=rStar
                alphaRight = (alphaRight+pi)/2;
                r1Right = real(evalfr(rFunc,exp(alphaRight*1i)));
            end
            % find the last w
            alpha(end) = utPIDFindIntersectionNewton(Type,rFunc,alphaRight,alphaLeft,r1Right,r1Left,rStar,'discrete');
        end
    end
end
