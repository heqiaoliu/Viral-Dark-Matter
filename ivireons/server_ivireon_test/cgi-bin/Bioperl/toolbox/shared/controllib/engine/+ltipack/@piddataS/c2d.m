function [PIDd,gic] = c2d(PIDc,Ts,options)
%C2D  Conversion of continuous time PID to discrete time.

%   Author(s): Rong Chen
%   Copyright 2009 MathWorks, Inc.
%	$Revision: 1.1.8.3 $  $Date: 2010/05/10 17:36:36 $

gic = [];
PIDd = PIDc;
PIDd.Ts = Ts;
EXP = exp(-Ts/PIDc.Td*PIDc.N);
switch lower(options.Method)
    case 'forwardeuler'
        % if method is ForwardEuler set Ts and Formulas directly.
        PIDd.IFormula = 'F';
        PIDd.DFormula = 'F';
    case 'backwardeuler'
        % if method is BackwardEuler set Ts and Formulas directly.
        PIDd.IFormula = 'B';
        PIDd.DFormula = 'B';
    case 'tustin'
        % if method is Tustin set Formulas to Trapezoidal.
        PIDd.IFormula = 'T';
        PIDd.DFormula = 'T';
        if options.PrewarpFrequency ~= 0
            w = options.PrewarpFrequency;
            TsPre = tan(Ts*w/2)/(w/2);
            PIDd.Ti = PIDd.Ti*Ts/TsPre;
            PIDd.Td = PIDd.Td*Ts/TsPre;
        end
    case 'zoh'
        % zoh(G(s),Ts) = (1-1/z)*Ztransform(G(s)/s) for Ts
        % s/(T*s+1) --> (1-1/z)*Z{1/(T*s+1)} = 1/T*(z-1)/(z-exp(-Ts/T))
        % default discretization method is Forward Euler
        % for Kp, Ti and N do not need to change
        if PIDc.Td>0
            if isinf(PIDc.N)
                ctrlMsgUtils.error('Control:transformation:c2d01','c2d');
            else
                PIDd.Td = Ts/(1-EXP)*PIDc.N;
            end
        end
        PIDd.IFormula = 'F';
        PIDd.DFormula = 'F';
    case 'foh'
        % foh(G(s),Ts) = (z-1)^2/Ts/z*Ztransform(G(s)/s^2) for Ts
        % 1/s --> Ts*(z+1)/2/(z-1)
        % s/(T*s+1) --> (1-exp(-Ts/T))*(z-1)/(z-exp(-Ts/T))/Ts
        % default discretization method is Trapezoidal
        % for Kp, Ti and Td do not need to change
        if PIDc.Td>0
            if isinf(PIDc.N)
                ctrlMsgUtils.error('Control:transformation:c2d01','c2d');
            else
                PIDd.N = PIDc.Td/(Ts/2*(1+EXP)/(1-EXP));
            end
        end
        PIDd.IFormula = 'T';
        PIDd.DFormula = 'T';
    case 'impulse'
        SSc = ss(PIDc);
        SSd = c2d(SSc,Ts,options);
        try
            PIDd = pidstd(SSd);
        catch ME
            throw(ME)
        end
    case 'matched'
        ZPKc = zpk(PIDc);
        ZPKd = c2d(ZPKc,Ts,options);
        try
            PIDd = pidstd(ZPKd);
        catch ME
            throw(ME)
        end
end
