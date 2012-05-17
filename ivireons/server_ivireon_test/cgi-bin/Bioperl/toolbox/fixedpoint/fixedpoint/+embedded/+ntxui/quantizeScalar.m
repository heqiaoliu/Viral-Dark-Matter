function qval = quantizeScalar(val,signed,wl,fl,rnd,rndIdx)
%Quantize a scalar value in floating point.
%  quantizeScalar(V,S,WL,FL,R) quantizes the scalar value V using signed
%  format S (true is signed, false is unsigned), word length WL, fraction
%  length FL, and round mode R (which may be 'floor', 'ceil', 'fix',
%  'zero', 'nearest','round', or 'convergent').
%
%   Only saturation is supported, not wrap.

%   If optional arg rndIdx is passed, string comparisons for round modes
%   are bypassed and the index is directly used.  This offers significant
%   speed-up for scalar streams.
%     1=floor, 2=ceil, 3=fix/zero, 4=nearest, 5=round, 6=convergent

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:20:34 $

% Determine data type limits
if signed
    maxVal =  pow2(wl-1)-1;
    minVal = -pow2(wl-1);
else
    maxVal = pow2(wl)-1;
    minVal = 0;
end
qrealmin    = pow2(-fl);
qrealmax    = maxVal*qrealmin;
qlowerbound = minVal*qrealmin;
qupperbound = qrealmax;

% Apply saturation to val
sval = val;
valSat = false;  % is value saturated?
if sval > qupperbound
    valSat = true;
    sval = qupperbound;
elseif sval < qlowerbound
    valSat = true;
    sval = qlowerbound;
end

% Here, aqval has absolute, saturated value, scaled up
asval = abs(sval);
asqval = asval/qrealmin;
eps_fl2 = eps/qrealmin;

% Round aqval based on residual
% Assess rounding
%   2.7 -> x32 = 86.4 -> 86 scaled
%        .5 -> 16 scaled
%
isNeg = sval<0;
fracAbsVal = asqval - fix(asqval); % fractional part after scaling up
fracOverHalf = fracAbsVal > 0.5;
fracIsHalf = abs(fracAbsVal-0.5) < eps_fl2;
% Need to be careful when determining equality with floating point
fracIsZero = fracAbsVal < eps_fl2;

% Determine whether we round "up" in an absolute-value sense
%    1=ceil, 2=convergent, 3=floor, 4=nearest, 5=round, 6=zero/fix
%
% Much more performance can be gained by COMMENTING OUT
% the "if nargin>5" check and the second "switch" case!
%
if nargin>5
    switch rndIdx
        case 1 % 'ceil'
            rndUpAbs = ~fracIsZero && ~isNeg;
        case 2 % 'convergent'
            isEven = rem(floor(asval),2)==0;
            rndUpAbs = fracOverHalf || ...
                (fracIsHalf && (~isNeg&&~isEven ||isNeg&&isEven));
        case 3 % 'floor'
            rndUpAbs = ~fracIsZero && isNeg;
        case 4 % 'nearest'
            rndUpAbs = fracAbsVal>=0.5;
        case 5 % 'round'
            rndUpAbs = fracOverHalf || fracIsHalf && ~isNeg;
        otherwise % {'zero','fix'}
            rndUpAbs = false;
    end
else
    switch rnd
        case 'nearest'
            rndUpAbs = fracAbsVal>=0.5;
        case 'round'
            rndUpAbs = fracOverHalf || fracIsHalf && ~isNeg;
        case 'floor'
            rndUpAbs = ~fracIsZero && isNeg;
        case {'zero','fix'}
            rndUpAbs = false;
        case 'ceil'
            rndUpAbs = ~fracIsZero && ~isNeg;
        otherwise % 'convergent'
            isEven = rem(floor(asval),2)==0;
            rndUpAbs = fracOverHalf || ...
                (fracIsHalf && (~isNeg&&~isEven ||isNeg&&isEven));
    end
end

% Apply rounding only if not saturated
if ~valSat && rndUpAbs % round up toward +inf?
    % Add lsbweight, which is qrealmin
    asqval = asqval+1;
end
asqval = fix(asqval)*qrealmin;

% Here, asqval has absolute, rounded, quantized, saturated value

if signed && isNeg
    qval = -asqval;
else
    qval = asqval;
end
