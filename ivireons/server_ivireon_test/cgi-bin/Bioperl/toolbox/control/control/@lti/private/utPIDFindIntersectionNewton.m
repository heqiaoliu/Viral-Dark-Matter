function w = utPIDFindIntersectionNewton(Axis,Func,wLB,wUB,KLB,KUB,K,Type)
% Singular frequency based P/PI/PID/PIDF Tuning sub-routine.
%
% This function computes the intersection between line K* and curve K(jw).
%
% Input arguments
%   Func:       K(jw) curve
%   KLB,KUB:    boundary Critical K values for two end points
%   WLB,WUB:    boundary w values for two end points
%   K:          K* line
%
% Output arguments
%   w:          frequencies at the intersections

%   Author(s): Rong Chen
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $ $Date: 2008/12/04 22:21:05 $
% stop iteration if w stop changing
w = wLB;
while abs(wLB-wUB)>(max(1,abs(wLB+wUB))*1e-14) && abs(KLB-KUB)>(max(1,abs(KLB+KUB))*1e-14)
    % first try Newton method
    w = ((KUB-K)*wLB+(K-KLB)*wUB)/(KUB-KLB);
    % if the new w is too close to either boundary, use the middle point
    % instead
    pos = (w-wLB)/(wUB-wLB);
    if pos<0.1 || pos>0.9
        w = (wLB+wUB)/2;
    end
    % evaluate new K value
    if strcmp(Type,'continuous')
        if strcmp(Axis,'Kp')
            % Func = real{1/G}
            KValue = real(evalfr(Func,1i*w));
        else
            % Func = imag{1/G}*j
            KValue = imag(evalfr(Func,1i*w))*w;
        end
    else
        KValue = real(evalfr(Func,exp(1i*w)));
    end
    % replace one of the boundaries until K value converges
    if (KValue-K)>sqrt(eps)
        wUB = w;
        KUB = KValue;
    elseif (KValue-K)<-sqrt(eps)
        wLB = w;
        KLB = KValue;
    else
        break;
    end
end
