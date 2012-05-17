function [c, q, tau] = utTuningIMC(P,tau)
%UTTUNINGIMC  Internal Model Controller (IMC) design for a SISO LTI model. 
%
%   C = UTTUNINGIMC(P) returns a classic feedback controller C which
%   stabilizes a SISO LTI plant P.  Controller C is designed to enforce
%   zero steady state offset when step input is tracked. Plant P has to be
%   SISO and proper(or biproper).   
%
%   C = UTTUNINGIMC(P,TAU) explicitly specifies the desired dominant
%   closed-loop time constant.  It should be adjusted to achieve better
%   robust stability and performance.  
%
%   [C, Q, TAU] = UTTUNINGIMC(P) returns the IMC controller Q that is used
%   in the standard one degree of freedom IMC structure.  Default dominant
%   closed-loop time constant TAU is also returned when it is not specified
%   as an input.
%
%   In this IMC design, the following assumptions are used:
%       1. IMC structure is one degree of freedom (1DF)
%       2. plant model is perfect (only nominal performance is considered)
%       3. unit negative feedback is used
%       4. one-parameter filter is used in the IMC controller Q
%       5. setpoint/disturbance inputs are step changes 
%       6. zero steady state offset is guaranteed
%
%   This IMC design is developed based on the contents from Chapter 2 to
%   Chapter 9 in "Robust Process Control" by Morari and Zefiriou 1989.
%
%   Remarks on a few issues when the plant is unstable:
%       1. the standard IMC structure loses internal stability and only the
%       classic feedback structure should be implemented.  
%       2. the classic feedback controller C itself may be unstable even
%       though the closed loop system is stable.  In those cases,
%       increasing the closed loop time constant TAU will possibly make the
%       controller stable.  
%       3. partial fraction expansion (PFE) of a ratio of polynomials is
%       used in the design, which numerically represents an ill-posed
%       problem. 
%
%   Author(s): R. Chen
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2007/12/14 14:25:29 $


%% parse: Model
if ~issiso(P)
    ctrlMsgUtils.error('Control:design:TuningRequiresSISOModel','IMC')
end
[isProper, P] = isproper(P);
if ~isProper
    ctrlMsgUtils.error('Control:design:TuningRequiresProperPlant','IMC')
end
% convert model into zpk format for IMC design
[Zero,Pole,Gain,Ts] = zpkdata(P,'v');
% treat undetermined sampling time (Ts=-1) as Ts=1
Ts = abs(Ts);
%  get open loop plant stability
IsStablePlant = isstable(P);

%% parse: dominant closed loop time constant tau
if nargin<2 || isempty(tau)
    % calculate filter time constant
    if IsStablePlant
        s = stepinfo(P);
        tau = s.SettlingTime/20;
        if isnan(tau) || (tau<=0)
            tau = 1;
        end
    else
        % REVISIT: need to initialized to the minimum tau value to make
        % sure that C is stable
        tau = 1;
    end
elseif ~isscalar(tau) || ~isreal(tau) || (tau<=0)
    ctrlMsgUtils.error('Control:design:IMCTuning1')
end

%% design IMC
% disable all the warning
s = warning('off'); [lw,lwid] = lastwarn; lastwarn('');
% compute IMC
if Ts==0
    % continuous model
    [c, q, errorID, errorMSG] = utIMC_1DFContinuous(Zero,Pole,Gain,tau);
else
    % discrete model
    [c, q, errorID, errorMSG] = utIMC_1DFDiscrete(Zero,Pole,Gain,Ts,exp(-Ts/tau));
end
% reset warning
warning(s); lastwarn(lw,lwid);
% if design fails, error out
if isempty(c)
    error(errorID,errorMSG);
end

%% check closed loop stability
if IsStablePlant
    CLSystem = P*q;
    if ~isstable(CLSystem)
        CLSystemMinreal = minreal(CLSystem);
        if ~isstable(CLSystemMinreal)
            ctrlMsgUtils.error('Control:design:TuningFailedToStabilize','IMC')   
        end
    end
else
    CLSystem = feedback(P*c,1);
    if ~isstable(CLSystem)
        CLSystemMinreal = minreal(CLSystem);
        if isstable(CLSystemMinreal)
            Poles = pole(minreal(c));
            if (Ts==0)&&any(Poles>sqrt(eps)) || (Ts>0)&&any(abs(Poles)>1+sqrt(eps))
                ctrlMsgUtils.error('Control:design:IMCTuning2')
            end
        else
            ctrlMsgUtils.error('Control:design:TuningFailedToStabilize','IMC')   
        end
    end
end
