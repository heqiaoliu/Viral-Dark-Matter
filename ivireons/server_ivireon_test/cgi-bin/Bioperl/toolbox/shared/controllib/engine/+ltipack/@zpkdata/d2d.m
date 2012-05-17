function D = d2d(D,Ts,options)
% Resample discrete model to target sampling interval Ts.

%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:26 $

Ts0 = D.Ts;
if Ts0==0 || Ts0==Ts
    % Static gain with Ts=0 or unchanged sample time
    D.Ts = Ts; return
end
[ny,nu] = size(D.k);

% Compute delays at new sampling time
% FIOD = normalized fractional delays wrt Ts, in [0,1)
D.Delay.Input = D.Delay.Input * Ts0;
D.Delay.Output = D.Delay.Output * Ts0;
D.Delay.IO = D.Delay.IO * Ts0;
[Delay,fiod] = discretizeDelay(D,Ts);

method = options.Method(1);

switch method
    case 't'
        % Tustin
        w = options.PrewarpFrequency;
        if w == 0
            % th = (c-c0)/(c+c0) with c0 = 2/Ts0 and c = 2/Ts
            th = (Ts0-Ts)/(Ts0+Ts);
        else
            c0 = w/tan(w*Ts0/2);  c = w/tan(w*Ts/2);
            th = (c-c0)/(c+c0);
        end
        
        % Round fractional delays to nearest multiple of Ts
        Delay = localRoundIODelay(Delay,fiod);
        
        % Loop over all SISO entries
        for ct=1:ny*nu
            z = D.z{ct};  p = D.p{ct};  k = D.k(ct);
            nz = length(z);  np = length(p);
            RealFlag = isreal(k) && isconjugate(z) && isconjugate(p);
            
            % Each factor (z0-rj) is transformed to
            %           (1 + th * rj) z - (rj + th)
            %           ---------------------------
            %                     (1 - th * z)
            % Handle zeros
            thzn = z + th;
            thzd = 1 + th * z;
            ix = (thzd~=0);
            z = thzn(ix)./thzd(ix);
            k = k * prod(thzd(ix)) * prod(-thzn(~ix));
            
            % Handle poles
            thpn = p + th;
            thpd = 1 + th * p;
            ix = (thpd~=0);
            p = thpn(ix)./thpd(ix);
            k = k / prod(thpd(ix)) / prod(-thpn(~ix));
            
            % Add contributions of zeros and poles at z=Inf
            if nz<np
                z(nz+1:np,:) = 1/th;   k = k * (-th)^(np-nz);
            elseif nz>np
                p(np+1:nz,:) = 1/th;   k = k / (-th)^(nz-np);
            end
            if RealFlag
                k = real(k);
            end
            D.z{ct} = z;  D.p{ct} = p;  D.k(ct) = k;
        end
        
    case 'z'
        % ZOH: Discretize each I/O transfer function using state-space algorithm
        % Compute equivalent FIOD at rate Ts0
        fiod = fiod*(Ts/Ts0);
        % Loop over I/O pairs
        Dzpk = ltipack.zpkdata({[]},{[]},1,Ts0); % SISO buffer
        for ct=1:ny*nu
            Dzpk.z = D.z(ct);
            Dzpk.p = D.p(ct);
            Dzpk.k = D.k(ct);
            if ~isproper(Dzpk)
                ctrlMsgUtils.error('Control:transformation:NotSupportedImproperZOH','d2d')
            end
            % Resample
            Dss = ss(Dzpk);
            Dss.Delay.Output = fiod(ct);  % to avoid increasing order
            Dzpkr = zpk(d2d(Dss,Ts,d2dOptions('Method','zoh')));
            % Update corresponding I/O pair in resampled ZPK
            D.z(ct) = Dzpkr.z;
            D.p(ct) = Dzpkr.p;
            D.k(ct) = Dzpkr.k;
            Delay.IO(ct) = Delay.IO(ct) + Dzpkr.Delay.Input + Dzpkr.Delay.Output;
        end
end

D.Ts = Ts;
D.Delay = Delay;


%---------------- Local functions --------------------------

function Delay = localRoundIODelay(Delay,fiod)
% Rounds fractional I/O delay
Delay.IO = Delay.IO + round(fiod);
if any(fiod(:))
    ctrlMsgUtils.warning('Control:transformation:RoundedDelay')
end
