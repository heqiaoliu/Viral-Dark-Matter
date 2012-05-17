function [PIDd,gic] = c2d(PIDc,Ts,options)
%C2D  Conversion of continuous time PIDP to discrete time.

%   Author(s): Rong Chen
%   Copyright 2009-2010 MathWorks, Inc.
%	$Revision: 1.1.8.2 $  $Date: 2010/05/10 17:36:33 $

gic = [];
PIDd = PIDc;
PIDd.Ts = Ts;
EXP = exp(-Ts/PIDc.Tf);
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
            PIDd.Ki = PIDd.Ki*TsPre/Ts;
            PIDd.Kd = PIDd.Kd*Ts/TsPre;
            PIDd.Tf = PIDd.Tf*Ts/TsPre;
        end
    case 'zoh'
        % zoh(G(s),Ts) = (1-1/z)*Ztransform(G(s)/s) for Ts
        % 1/s --> Ts/(z-1)
        % s/(Tf*s+1) --> (1-1/z)*Z{1/(Tf*s+1)} = 1/Tf*(z-1)/(z-exp(-Ts/Tf))
        % default discretization method is Forward Euler
        if PIDc.Kd~=0
            if PIDc.Tf==0
                ctrlMsgUtils.error('Control:transformation:c2d01','c2d');
            else
                PIDd.Tf = Ts/(1-EXP);
                PIDd.Kd = PIDc.Kd/PIDc.Tf*PIDd.Tf;
            end
        end
        PIDd.IFormula = 'F';
        PIDd.DFormula = 'F';
    case 'foh'
        % foh(G(s),Ts) = (z-1)^2/Ts/z*Ztransform(G(s)/s^2) for Ts
        % 1/s --> Ts*(z+1)/2/(z-1)
        % s/(Tf*s+1) --> (1-exp(-Ts/Tf))*(z-1)/(z-exp(-Ts/Tf))/Ts
        % default discretization method is Trapezoidal
        if PIDc.Kd~=0
            if PIDc.Tf==0
                ctrlMsgUtils.error('Control:transformation:c2d01','c2d');
            else
                PIDd.Tf = Ts*(1+EXP)/2/(1-EXP);
            end
        end
        PIDd.IFormula = 'T';
        PIDd.DFormula = 'T';
    case 'impulse'
        SSc = ss(PIDc);
        SSd = c2d(SSc,Ts,options);
        try
            PIDd = pid(SSd);
        catch ME
            throw(ME)
        end
    case 'matched'
        ZPKc = zpk(PIDc);
        ZPKd = c2d(ZPKc,Ts,options);
        try
            PIDd = pid(ZPKd);
        catch ME
            throw(ME)
        end
end
