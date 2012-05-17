function [Dd,ICMap] = utDiscretizeTustin(Dc,Ts,options)
%UTDISCRETIZETUSTIN is a utility to discretize SS models based on Tustin's
%method.

%   Author(s): P. Gahinet, Murad Abu-Khalaf, August 10, 2009
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:32:00 $

% Handle prewarp
w = options.PrewarpFrequency;
if w == 0
    T = Ts;
else
    % Handle prewarping
    T = 2*tan(w*Ts/2)/w;
end

% Get LFT's dimensions
nx = size(Dc.a,1);
nfd  = numel(Dc.Delay.Internal);   % nfd=nw=nz
ny = size(Dc.d,1) - nfd;
nu = size(Dc.d,2) - nfd;

% Get Fractional Delays options
nf = options.FractDelayApproxOrder;
roundOK = (nf == 0);
delayOK = strcmpi(options.FractDelayModeling,'delay');

% Extract discrete external delays
[Delay,fid,fod,ffd] = discretizeDelay(Dc,Ts);

%% Compute discrete matrices
if isempty(Dc.e)
    % Explicit SS
    m = eye(nx) - (T/2)*Dc.a;
    % Prevent scaling-induced "near singularity" (g330910)
    [ms,bs,cs,~,s] = aebalance(m,Dc.b,Dc.c,[],'safebal','noperm');
    [l,u,p] = lu(ms,'vector');
    if rcond(u)<eps,
        ctrlMsgUtils.error('Control:transformation:c2d10')
    end
    si = 1./s;
    aux = eye(nx) + (T/2)*lrscale(Dc.a,si,s);
    ad = u\(l\aux(p,:));      % (I - a*T/2)\(I + a*T/2)
    bd = u\(l\bs(p,:));       % (I - a*T/2)\b
    cd = zeros(size(cs));
    cd(:,p) = T*((cs/u)/l);   % T*c/(I - a*T/2)
    dd = (cd*bs)/2 + Dc.d;  % (T/2)*c*(I - a*T/2)\b + d
    ad = lrscale(ad,s,si);
    bd = lrscale(bd,s,[]);
    cd = lrscale(cd,[],si);
    ed = [];
    % The Tustin appx is
    %    w[k+1] = Ad w[k] + Bd u[k],   y[k] = Cd w[k] + Dd u[k]
    % where  w(t) = (I-A*T/2)/T x(t) - B/2 u(t).
else
    % Descriptor SS
    a = Dc.a;   e = Dc.e;
    m = e - (T/2)*a;
    % Prevent scaling-induced "near singularity"
    [ms,bs,cs,~,s] = aebalance(m,Dc.b,Dc.c,[],'safebal','noperm');
    [l,u,p] = lu(ms,'vector');
    if rcond(u)<eps,
        ctrlMsgUtils.error('Control:transformation:c2d10')
    end
    aux = zeros(size(cs));
    aux(:,p) = T*((cs/u)/l);
    dd = (aux*bs)/2 + Dc.d;  % (T/2)*c/(e - a*T/2)*b + d
    ad = e + (T/2)*a;        % e + a*T/2
    bd = Dc.b;               % b
    cd = lrscale(aux,[],1./s) * e;  % T*c/(e - a*T/2)*e
    ed = m;                  % e - a*T/2
end

%% Synthesize SS
Dd = ltipack.ssdata(ad,bd,cd,dd,ed,Ts); % Note: Discard state names because xd[k] = (I-A*T/2)/T xc(t) - B/2 u[k]

%% Handle fractional delays
if any(ffd) && ~roundOK
    % Approximate using Thiran filters
    appxInternalDelays = min(Delay.Internal,nf-1) .* (ffd>0);
    G = getFractionalFilterBlock(appxInternalDelays+ffd,Ts,delayOK);
    G.Delay.Output = Delay.Internal - appxInternalDelays;
    Dd = lft(Dd,G,nu+(1:nfd),ny+(1:nfd),1:nfd,1:nfd); % nfd size may decrease
else
    % Round delays to nearest multiple of Ts
    Dd.Delay = ltipack.utDelayStruct(ny,nu,true);
    Dd.Delay.Internal = Delay.Internal + round(ffd);    
end
% Note: At this point Dd is well formed with correct dimensions for
% Dd.Delay for the MTIMES operations below.

if any(fid) && ~roundOK
    % Approximate using Thiran filters
    appxInputDelays = min(Delay.Input,nf-1) .* (fid>0);
    G = getFractionalFilterBlock(appxInputDelays+fid,Ts,delayOK);
    Dd = mtimes(Dd,G); % Dd*G
    Dd.Delay.Input = Delay.Input-appxInputDelays;
else
    % Round delays to nearest multiple of Ts
    Dd.Delay.Input = Delay.Input + round(fid);
end

if any(fod) && ~roundOK
    % Approximate using Thiran filters
    appxOutputDelays = min(Delay.Output,nf-1) .* (fod>0);
        G = getFractionalFilterBlock(appxOutputDelays+fod,Ts,delayOK);
        % Multiply by the Output Delays. This results in the first states being those of G
        Dd = mtimes(G,Dd); % G*Dd
        Dd.Delay.Output = Delay.Output-appxOutputDelays;
        % Reorder states so that original states are in upper left corner.
        % Only applicable to FractDelayModeling = 'state'
        if ~delayOK
            nxDd = size(Dd.a,2);
            nxG  = size(G.a,2);
            perm = [nxG+1:nxDd 1:nxG];
            Dd.a = Dd.a(perm,perm);
            Dd.b = Dd.b(perm,:);
            Dd.c = Dd.c(:,perm);
            if ~isempty(Dd.e)
                Dd.e = Dd.e(perm,perm);
            end
        end
else
    Dd.Delay.Output = Delay.Output + round(fod);
end

if roundOK && (any(fid) || any(fod) || any(ffd))
    ctrlMsgUtils.warning('Control:transformation:RoundedDelay')
end

% Eliminate zero internal delays (may be introduced by rounding)
% Note: Allow improper/augmented result since this is not used directly for simulation
Dd = elimZeroDelay(Dd);

%% Compute IC Mapping:   w[0] = G * [x0;u0]
if nargout > 1
    if roundOK
        NoInputDelay = double(~any(Dd.Delay.Input));
    else
        NoInputDelay = double(~any(Dd.Delay.Input+fid));
    end
    ICMap = [m/T , -(NoInputDelay/2)*Dc.b];
    if ~isempty(Dc.e)
        % may throw warning if E is singular
        ICMap = e\ICMap;
    end
    % Zero padding extra states
    nxnew = size(Dd.a,1)-nx;
    ICMap = [ICMap;
        zeros(nxnew,size(ICMap,2))];
end
end

% -------------------------- Local functions-----------------------------%
function G = getFractionalFilterBlock(delayAppx,Ts,delayOK)
%% Returns fractional filter block.

n = numel(delayAppx);
a = []; b = []; c = []; d = [];

for ct = 1:n
    if rem(delayAppx(ct),1)>0
        [ax,bx,cx,dx] = thirancoef(delayAppx(ct),1);
    else
        ax = []; bx=zeros(0,1); cx=zeros(1,0); dx =1;
    end
    a = blkdiag(a,ax);
    b = blkdiag(b,bx);
    c = blkdiag(c,cx);
    d = blkdiag(d,dx);
end

if delayOK % FractDelayModeling = 'delay'
    % Realize dynamics as internal delays
    [ny,nu] = size(d); nx = size(a,1);
    G = ltipack.ssdata([],zeros(0,nu+nx),zeros(ny+nx,0),[d c;b a],[],Ts);
    G.Delay = ltipack.utDelayStruct(ny,nu,true);
    G.Delay.Internal = ones(nx,1);
else
    % Realize dynamics as states
    G = ltipack.ssdata(a,b,c,d,[],Ts);
end

end
