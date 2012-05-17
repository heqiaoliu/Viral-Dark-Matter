function [c, Kp, Ki, Kd, N] = utPIDfromKTTtoKKKN(Model,Kc,Ti,Td,Nin,Type)
% Convert PID parameters from Kc/Ti/Td to Kp/Ki/Kd/N format (continuous)

%   Author(s): Rong Chen
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2008/12/04 22:21:24 $

%% ----------------------------------------------------------------
% initialize outputs
% ----------------------------------------------------------------
c = zpk; Kp = []; Ki = []; Kd = []; N = Nin;
%% ------------------------------------------------------------------------
% obtain Kp/Ki/Kd/N from K/Ti/Td
% ----------------------------------------------------------------
if isinf(Kc)
    return
else
    switch Type
        case 'p'
            Kp = Kc;
            Ki = [];
            Kd = [];
            N = [];
            c = zpk(Kc);
        case 'pi'
            Kp = Kc;
            Ki = Kc/Ti;
            Kd = [];
            N = [];
            c = zpk(tf([Kp Ki],[1 0]));
        case 'pid'
            Kp = Kc;
            Ki = Kc/Ti;
            Kd = Kc*Td;
            if isinf(Nin)
                N = inf;
                c = zpk(tf([Kd Kp Ki],[1 0]));
            elseif isempty(Nin)
                N = 10/Td;
                c = zpk(tf([Kp/N+Kd Kp+Ki/N Ki],[1/N 1 0]));    
            else
                N = Nin;
                c = zpk(tf([Kp/N+Kd Kp+Ki/N Ki],[1/N 1 0]));
            end
    end
    % when a discrete PID is needed, c2d is used to generate a discrete PID
    % discretized directly from the continuous PID controller
    Ts = abs(getTs(Model));
    if Ts>0
        c = c2d(c,Ts,'matched');
    end
end