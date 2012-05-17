function [Dd,gic] = c2d(Dc,Ts,options)
%C2D  Continuous-to-discrete conversion of zero/pole/gain models.

%   Author(s): P. Gahinet
%   Revised: Murad Abu-Khalaf
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $ $Date: 2009/11/09 16:33:21 $

gic = [];
[ny,nu] = size(Dc.k);
Dd = Dc;

method = options.Method(1);

switch method
    case 'm'
        % Matched pole-zero
        if ny~=1 || nu~=1
            ctrlMsgUtils.error('Control:transformation:MatchedMethodRequiresSISOModel','c2d')
        end
        
        z = Dc.z{1};
        p = Dc.p{1};
        RealFlag = isreal(Dc.k) && isconjugate(z) && isconjugate(p);
        
        % Zero/pole r mapped to exp(r*Ts)
        zd = exp(z*Ts);
        pd = exp(p*Ts);
        
        % Guard against overflow
        if ~all(isfinite(zd)) || ~all(isfinite(pd))
            ctrlMsgUtils.error('Control:transformation:c2d02')
        end
        
        % Map zeros at infinity to z=-1 except one (see Franklin-Powell, 3a. on p.61)
        zd = [zd; -ones(length(pd)-length(zd)-1,1)];
        
        % Match D.C. gain or gain at s0=1e-3/Ts for systems with integrator.
        % The s0 value should be consistent with the one used in D2C.
        % RE: s = sm -> z = exp(Ts*sm)
        sm = 0;
        while any(abs([z;p]-sm)<sqrt(eps)),
            sm = sm + 1e-3/Ts;
        end
        zm = exp(sm*Ts);
        dcc = Dc.k*prod(sm-z)/prod(sm-p);
        kd = dcc*prod(zm-pd)/prod(zm-zd);
        if RealFlag
            kd = real(kd);
        end
        
        Dd.z = {zd};
        Dd.p = {pd};
        Dd.k = kd;
        
        % Discretize delays: Extract discrete delays (all fractional delays
        % are absorbed into I/O delay matrix)
        [Delay,fiod] = discretizeDelay(Dc,Ts);
        % Handle fractional delays if any
        if any(fiod)
            Dd = handleFractionalDelays(Dd,Delay,fiod,options);
        else
            Dd.Delay = Delay;
        end
        
    case 't'
        % Tustin approximation
        w = options.PrewarpFrequency;
        if w == 0
            c = 2/Ts;
        else
            c = w/tan(w*Ts/2);
        end
        
        % Loop over all SISO entries
        for ct=1:ny*nu
            z = Dc.z{ct};
            p = Dc.p{ct};
            k = Dc.k(ct);
            lpmz = length(p) - length(z);
            RealFlag = isreal(k) && isconjugate(z) && isconjugate(p);
            
            % Each factor (s-rj) is transformed to
            %           (2/T - rj) z - (2/T + rj)
            %           -------------------------
            %                     z + 1
            % Handle zeros first:
            cmz = c - z;   % 2/T-z
            cpz = c + z;   % 2/T+z
            ix = (cmz==0);
            % Zeros s.t. 2/T-zj~=0 mapped to (2/T+zj)/(2/T-zj), other contribute to gain
            z = cpz(~ix,:) ./ cmz(~ix,:);
            k = k * prod(-cpz(ix,:)) * prod(cmz(~ix,:));
            
            % Then handle poles:
            cmp = c - p;   % 2/T-p
            cpp = c + p;   % 2/T+p
            ix = (cmp==0);
            % Poles s.t. 2/T-pj~=0 mapped to (2/T+pj)/(2/T-pj), other contribute to gain
            p = cpp(~ix,:) ./ cmp(~ix,:);
            k = k / prod(-cpp(ix,:)) / prod(cmp(~ix,:));
            if RealFlag
                k = real(k);
            end
            
            % (z+1) factors may contribute additional poles or zeros
            Dd.z{ct} = [z ; -ones(lpmz,1)];
            Dd.p{ct} = [p ; -ones(-lpmz,1)];
            Dd.k(ct) = k;
        end
        
        % Discretize delays: Extract discrete delays (all fractional delays
        % are absorbed into I/O delay matrix)
        [Delay,fiod] = discretizeDelay(Dc,Ts);
        % Handle fractional delays if any
        if any(fiod)
            Dd = handleFractionalDelays(Dd,Delay,fiod,options);
        else
            Dd.Delay = Delay;
        end
        
    case {'z' 'f' 'i'}
        % Discretize each I/O transfer function using state-space algorithm
        Dzpk = ltipack.zpkdata({[]},{[]},1,0); % SISO buffer
        
        % Extract discrete delays (all fractional delays are absorbed into I/O delay matrix)
        [Delay,fiod] = discretizeDelay(Dc,Ts);
        
        % To minimize the order of the discretized model, push all residual
        % delays to the input for the IMP and FOH methods, and to the
        % output for the ZOH method (cf. g166286)
        if strcmp(method,'z')
            ioField = 'Output';
        else
            ioField = 'Input';
        end
        
        % Loop over I/O pairs
        for ct=1:ny*nu
            Dzpk.z = Dc.z(ct);
            Dzpk.p = Dc.p(ct);
            Dzpk.k = Dc.k(ct);
            if ~isproper(Dzpk)
                ctrlMsgUtils.error('Control:transformation:c2d01','c2d')
            end
            % Discretize
            Dss = ss(Dzpk);
            Dss.Delay.(ioField) = fiod(ct)*Ts;  % to avoid increasing order
            Dzpkd = zpk(c2d(Dss,Ts,options));
            % Update corresponding I/O pair in discrete TF
            Dd.z(ct) = Dzpkd.z;
            Dd.p(ct) = Dzpkd.p;
            Dd.k(ct) = Dzpkd.k;
            Delay.IO(ct) = Delay.IO(ct) + Dzpkd.Delay.Input + Dzpkd.Delay.Output;
        end
        Dd.Delay = Delay;
end
Dd.Ts = Ts;

end

%---------------- Local functions --------------------------

function Dd = handleFractionalDelays(Dd,Delay,fiod,options)

% Fractional delay options
nf = options.FractDelayApproxOrder;
roundOK = (nf == 0);

if roundOK
    % Round fractional delays to nearest multiple of Ts
    Delay.IO = Delay.IO + round(fiod);
    ctrlMsgUtils.warning('Control:transformation:RoundedDelay')
else
    [ny,nu] = size(fiod);
    
    % Combine all discrete delays and use a portion for Thiran filters
    IODelay = Delay.IO + Delay.Output(:,ones(1,nu)) + Delay.Input(:,ones(1,ny)).';
    
    % Remove approximated delays, and keep the rest of the delay chain
    appxIODelays = min(IODelay,nf-1) .* (fiod>0);
    
    % Augment IO fractional delay filters
    for ct =1:ny*nu
        % Note: [z,p,k]=thirancoef(0,1) gives z=Empty0x1, p=Empty0x1, k=1
        [zio,pio,kio] = thirancoef(appxIODelays(ct)+fiod(ct),1);
        Dd.z{ct} = [Dd.z{ct} ; zio];
        Dd.p{ct} = [Dd.p{ct} ; pio];
        Dd.k(ct) = Dd.k(ct) * kio;
    end
    
    % Subtract the portion used for the Thiran filter form the total
    % I/O delays and restore a maximal subset of the discrete input
    % and output delays.
    [Delay.IO,Delay.Input,Delay.Output] = restoreInputOutputDelays(...
        IODelay-appxIODelays,Delay.Input,Delay.Output);
end
Dd.Delay = Delay;
end


function [io,u,y] = restoreInputOutputDelays(io,u,y)
% Restore I/O delays (if possible) by subtracting them from IO delay matrix
[ny,nu] = size(io);
u = min(min(io),u.').';
io = io - u(:,ones(1,ny)).';
y = min(min(io,[],2),y);
io = io - y(:,ones(1,nu));
end
