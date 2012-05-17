function Dr = d2d(D,Ts,options)
% Resample discrete state-space model to Ts.

%	Author(s): A. Grace, P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:51 $

Ts0 = D.Ts;
if Ts0==0
    % Static gain with Ts=0
    Dr = D;  Dr.Ts = Ts; return
end

method = options.Method(1);

switch method
    case 't'
        % Tustin resampling
        w = options.PrewarpFrequency;
        if w == 0
            % th = (c-c0)/(c+c0) with c0 = 2/Ts0 and c = 2/Ts
            th = (Ts0-Ts)/(Ts0+Ts);
        else
            c0 = w/tan(w*Ts0/2);  c = w/tan(w*Ts/2);
            th = (c-c0)/(c+c0);
        end
        
        % Compute delays at new sampling time and round to
        % nearest sampling period
        D.Delay.Input = D.Delay.Input * Ts0;
        D.Delay.Output = D.Delay.Output * Ts0;
        D.Delay.Internal = D.Delay.Internal * Ts0;
        [Delay,fid,fod,ffd] = discretizeDelay(D,Ts);
        
        % Round delays to nearest multiple of Ts
        if any(fid) || any(fod) || any(ffd)
            ctrlMsgUtils.warning('Control:transformation:RoundedDelay')
        end
        Delay.Input = Delay.Input + round(fid);
        Delay.Output = Delay.Output + round(fod);
        Delay.Internal = Delay.Internal + round(ffd);
        
        % Compute matrices for resampled model
        nx = size(D.a,1);
        tau = sqrt(1-th^2);
        if isempty(D.e)
            % Explicit SS
            m = eye(nx) + th * D.a;  % I + th * a
            % Prevent scaling-induced "near singularity" (g330910)
            [ms,bs,cs,~,s] = aebalance(m,D.b,D.c,[],'safebal','noperm');
            [l,u,p] = lu(ms,'vector');
            if rcond(u)<eps,
                ctrlMsgUtils.error('Control:transformation:d2d08')
            end
            si = 1./s;
            aux = lrscale(D.a,si,s) + th * eye(nx);  % a + th * I
            ad = u\(l\aux(p,:));      % (a + th * I)\(I + th * a)
            bd = u\(l\bs(p,:));       % (a + th * I)\b
            cd = zeros(size(cs));
            cd(:,p) = ((cs/u)/l);      % c/(a + th * I)
            dd = D.d - th * cs * bd;  % d - th * c * (a + th * I)\b
            ad = lrscale(ad,s,si);
            bd = lrscale(bd,tau*s,[]);
            cd = lrscale(cd,[],tau*si);
            ed = [];
        else
            % Descriptor SS
            % Descriptor SS
            a = D.a;   e = D.e;
            m = e + th * a;
            % Prevent scaling-induced "near singularity"
            [ms,bs,cs,~,s] = aebalance(m,D.b,D.c,[],'safebal','noperm');
            [l,u,p] = lu(ms,'vector');
            if rcond(u)<eps,
                ctrlMsgUtils.error('Control:transformation:d2d08')
            end
            aux = zeros(size(cs));
            aux(:,p) = ((cs/u)/l);  % c/(e+th*a)
            dd = D.d - th*aux*bs;  % d-th*c/(e+th*a))*b
            ad = a + th * e ;      % a + th * e
            bd = tau * D.b;        % tau*b
            cd = lrscale(aux,[],tau./s) * e;  % tau*c/(e+th*a)*e
            ed = m;                % e + th * a
        end
        Dr = ltipack.ssdata(ad,bd,cd,dd,ed,Ts);
        Dr.Delay = Delay;
        
        % Eliminate zero internal delays (after rounding)
        % Note: May result in improper model
        Dr = elimZeroDelay(Dr);
        
    case 'z'
        % ZOH resampling
        rTs = Ts/Ts0; % sample time ratio
        FractionalResampling = (abs(round(rTs)-rTs)>sqrt(eps)*rTs);
        if ~FractionalResampling
            rTs = round(rTs);
        end
        
        % Check causality
        [isProper,D] = isproper(D,'explicit');
        if ~isProper
            ctrlMsgUtils.error('Control:transformation:NotSupportedImproperZOH','d2d')
        end
        
        % Delay handling
        id = D.Delay.Input/rTs;    rid = round(id);
        od = D.Delay.Output/rTs;   rod = round(od);
        fd = D.Delay.Internal/rTs; rfd = round(fd);
        tolint = 1e4*eps;
        FractionalDelay = (any(abs(id-rid)>tolint) || ...
            any(abs(od-rod)>tolint) || any(abs(fd-rfd)>tolint));
        
        % Extract data
        [a,b1,b2,~,~,d11,~,~,d22] = getBlockData(D);
        
        % Look for real negative poles
        if FractionalResampling
            p = eig(a);
            RealNegPole = any(imag(p)==0 & real(p)<=0);
        end
        
        % Resample
        if FractionalDelay || (FractionalResampling && RealNegPole)
            % Fractional delays or negative real poles with fractional resampling:
            % let D2C/C2D handle it
            try
                pC2D = c2dOptions('Method','zoh');
                pD2C = c2dOptions('Method','zoh');                
                Dr = c2d(d2c(D,pD2C),Ts,pC2D);
            catch E
                error(E.identifier,strrep(E.message,'d2c','d2d'))
            end
        else
            % Proceed directly
            nx = size(a,1);
            nu = size(d11,2);
            nfd = length(d22);
            % Resample
            M = [a b1 b2;zeros(nu+nfd,nx) eye(nu+nfd)];
            if FractionalResampling
                [s,~,M] = mscale(M,'noperm','safebal');
                M = expm(rTs*logm(M));
                M = lrscale(M,s,1./s);
            else
                M = M^rTs;
            end
            if isreal(a) && isreal(b1) && isreal(b2)
                M = real(M);
            end
            % Create result
            Dr = ltipack.ssdata(M(1:nx,1:nx),M(1:nx,nx+1:nx+nu+nfd),D.c,D.d,[],Ts);
            Dr.Delay.Input = rid;
            Dr.Delay.Output = rod;
            Dr.Delay.Internal = rfd;
            Dr.StateName = D.StateName;
            Dr.StateUnit = D.StateUnit;
        end
end
