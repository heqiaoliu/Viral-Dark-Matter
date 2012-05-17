function [c, Kp, Ki, Kd, N] = utPID_ZNClosedLoop(Model,Type,Target,Nin)
% Ziegler-Nichols Closed Loop Tuning (Frequency Response Method)
%   This heuristic PID design method applies to stable plant only.  The
%   method relies on the existence of ultimate gain and frequency.  
%
% Note:
%   1.  for a discrete plant, PID is obtained by discretizing a continuous PID controller 
%   2.  for a PID design, when N is empty it is computed as 10*Kp/Kd 

%   Author(s): Rong Chen
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2008/12/04 22:21:22 $

%% Calculate untimate gain and frequency
% get sampling time
Ts = abs(getTs(Model)); 
if Ts==0
    % make sure the model has positive gain for Ku computation
    Sign = sign(evalfr(Model,0)-evalfr(Model,inf));
else
    % make sure the model has positive gain for Ku computation
    Sign = sign(dcgain(Model));
end
% compute Wu
result = allmargin(Sign*Model);
if isempty(result.GMFrequency)
    ctrlMsgUtils.error('Control:design:PIDTuning14');
else
    Wu = result.GMFrequency(1);
    Ku = result.GainMargin(1);
    if isfinite(Wu) && isfinite(Ku) && Wu~=0
        [Kc,Ti,Td] = KTTfromKuTu(Ku,Wu,Type,Target);
        Kc = Sign*Kc;
        [c, Kp, Ki, Kd, N] = utPIDfromKTTtoKKKN(Model,Kc,Ti,Td,Nin,Type);    
    else
        ctrlMsgUtils.error('Control:design:PIDTuning14');
    end
end

%% -------------------------------------------------------------------------
% get ultimate frequency and period
% -------------------------------------------------------------------------
function [Kc,Ti,Td] = KTTfromKuTu(Ku,Wu,Type,LoopUpTable)
% get Tu
Tu = 2*pi/Wu;
% look up table
Ti = [];
Td = [];
switch LoopUpTable
    case 'ORIGINAL'
        switch Type
            case 'p'
                Kc = 0.5*Ku;
            case 'pi'
                Kc = 0.4*Ku;
                Ti = 0.8*Tu;
            case 'pid'
                Kc = 0.6*Ku;
                Ti = 0.5*Tu;
                Td = 0.125*Ti;
        end
     case 'LUYBEN'
        switch Type
            case 'p'
                Kc = 0.4*Ku;
            case 'pi'
                Kc = 0.31*Ku;
                Ti = 2.2*Tu;
            case 'pid'
                Kc = 0.45*Ku;
                Ti = 2.2*Tu;
                Td = 0.16*Tu;
        end
     case 'ASTROM'
        rB = 0.3;
        phiB = pi/9;
        alpha = 0.25;
        switch Type
            case 'p'
                Kc = Ku*rB;
            case 'pi'
                Kc = Ku*rB*cos(phiB);
                Ti = Tu/pi/tan(phiB);
            case 'pid'
                Kc = Ku*rB*cos(phiB);
                Ti = Tu/pi/(1-sin(phiB))/cos(phiB);
                Td = alpha*Ti;
        end
end

