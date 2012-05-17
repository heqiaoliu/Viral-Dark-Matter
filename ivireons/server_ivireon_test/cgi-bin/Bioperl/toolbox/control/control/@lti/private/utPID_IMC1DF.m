function [c, Kp, Ki, Kd, N] = utPID_IMC1DF(Model,Type,Tau,Nin)
% 1DF IMC Based PID Tuning
%   This heuristic PID design method applies to stable plant only. After
%   the IMC controller is obtained, it is reduced to a PID controller
%   through Taylor expansion at s=0 (z=1).
% 
%   Tau is a potitive real number for desired closed loop time constant
%
%   when Nin is 
%       N/A or empty:   N is computed 
%       infinite:       C is pure PID
%       otherwise:      C is filtered PID with custom N
% 
%   In discrete case, only C is returned

%   Author(s): Rong Chen
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2008/12/04 22:21:19 $

%% initialize outputs
c = zpk; Kp = []; Ki = []; Kd = []; N = Nin;

%% calculate 1DF IMC
try
    cIMC = minreal(utTuningIMC(Model,Tau));
catch ME
    ctrlMsgUtils.error('Control:design:PIDTuning10');
end

%% generate PID from IMC by using Maclaurin expansion on c after an
%% integrator is removed from cIMC
Ts = abs(getTs(Model)); 
if Ts==0
    % continuous
    % let c(s)=f(s)/s, then PID = (f(0)+f'(0)*s+f''(0)/2*s^2)/s
    % remove the integrator
    [NumC,DenC] = tfdata(cIMC,'v');
    DenC = DenC(1:end-1);
    k = NumC(end)/DenC(end);
    NumC = fliplr(NumC/NumC(end));
    DenC = fliplr(DenC/DenC(end));
    % compute pid parameters
    alpha = zeros(1,3);
    alpha(1:min(3,length(NumC))) = NumC(1:min(3,length(NumC)));
    beta = zeros(1,3);
    beta(1:min(3,length(DenC))) = DenC(1:min(3,length(DenC)));
    switch Type
        case 'p'
            Kp = k*(alpha(2)-beta(2));
            c = zpk([],[],Kp);
        case 'pi'
            c = balred(cIMC,1);
            Num = tfdata(c,'v');
            Kp = Num(1);
            Ki = Num(2);
        case 'pid'
            if isempty(N)
                % design filter too
                c = balred(cIMC,2);
                [Num Den] = tfdata(c,'v');
                N = Den(2);
                T = [1 0 N;N 1 0;0 N 0];
                Val = T\Num';
                Kp = Val(1);
                Ki = Val(2);
                Kd = Val(3);            
            else
                % no filter or given filter pole N
                Kp = k*(alpha(2)-beta(2));
                Ki = k;
                Kd = k*(alpha(3)+beta(2)^2-beta(3)-alpha(2)*beta(2));
                if isinf(N)
                    c = zpk(tf([Kd Kp Ki],[1 0]));
                else
                    c = zpk(tf([Kp/N+Kd Kp+Ki/N Ki],[1/N 1 0]));
                end
            end
    end
% discrete
% let c(z)=g(z)/z/(z-1), then PID = (g(0)+g'(0)*z+g''(0)/2*z^2)/(z-1)/z
else
    switch Type
        case 'p'
            [Zero,Pole,Gain] = zpkdata(cIMC,'v');
            [junk,ind]=sort(abs(Pole-1));
            Pole = Pole(ind(2:end));
            Zero = [0;Zero];
            [NumC,DenC] = tfdata(zpk(Zero,Pole,Gain,Ts),'v');
            NumC = NumC(end-length(Zero):end);
            DenC = DenC(end-length(Pole):end); 
            [num1 den1] = polyder(NumC,DenC);
            g1 = polyval(num1,1)/polyval(den1,1);
            c = zpk([],[],g1,Ts);
        case 'pi'
            c = balred(cIMC,1);
        case 'pid'
            c = balred(cIMC,2);
            if isinf(N)
                [Z,P,K] = zpkdata(c,'v');
                P = [0;1];
                c = zpk(Z,P,K,Ts);
            elseif ~isempty(N)
                [Z,P,K] = zpkdata(c,'v');
                P = [1/(1+Ts*N);1];
                c = zpk(Z,P,K,Ts);
            end
    end
end

