function D = d2d(D,Ts,options)
% Resample discrete model to target sampling interval Ts.

%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:31 $

Ts0 = D.Ts;
if Ts0==0 || Ts0==Ts
    % Static gain with Ts=0 or unchanged sample time
    D.Ts = Ts; return
end

method = options.Method(1);

switch method
    case 't'
        % Tustin
        D = tf(d2d(zpk(D),Ts,options));
    case 'z'
        % ZOH: Resample each I/O transfer function using the state-space algorithm
        [ny,nu] = size(D.num);
        % Compute discrete delays for resampled system
        D.Delay.Input = D.Delay.Input * Ts0;
        D.Delay.Output = D.Delay.Output * Ts0;
        D.Delay.IO = D.Delay.IO * Ts0;
        % FIOD = normalized fractional delays wrt Ts, in [0,1)
        [Delay,fiod] = discretizeDelay(D,Ts);
        fiod = fiod*(Ts/Ts0);
        % Loop over I/O pairs
        Dtf = ltipack.tfdata({[]},{[]},Ts0);
        for ct=1:ny*nu
            Dtf.num = D.num(ct);
            Dtf.den = D.den(ct);
            if ~isproper(Dtf)
                ctrlMsgUtils.error('Control:transformation:NotSupportedImproperZOH','d2d')
            end
            % Resample
            Dss = ss(Dtf);
            Dss.Delay.Output = fiod(ct);  % to avoid increasing order            
            Dtfr = tf(d2d(Dss,Ts,d2dOptions('Method','zoh')));
            % Update corresponding I/O pair in resampled TF
            D.num(ct) = Dtfr.num;
            D.den(ct) = Dtfr.den;
            Delay.IO(ct) = Delay.IO(ct) + Dtfr.Delay.Input + Dtfr.Delay.Output;
        end
        % Update sampling time and delays
        D.Ts = Ts;
        D.Delay = Delay;
end
