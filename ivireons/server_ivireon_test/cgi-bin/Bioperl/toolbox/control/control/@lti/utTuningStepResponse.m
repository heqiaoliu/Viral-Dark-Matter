function C = utTuningStepResponse(Model,Type,Rule)
% Tuning PID based on open loop step response
%   Rules apply to a stable or integrating plant in three steps:
%   1. generate a step response, which is called process reaction curve
%   2. approximate it with one of the following models: 
%       (1) K/(T*s+1)*exp(-L*s)
%       (2) K/s*exp(-L*s)
%       (3) K/(T*s+1)
%       (4) K/s
%   3. find Kp Ti Td N based on the specified rule.
%
%   C is returned as a @pidstd object. When designing PID with derivative
%   filter, N is always set to 10. 

%   Author(s): Rong Chen
%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:29:32 $

hw = ctrlMsgUtils.SuspendWarnings;  %#ok<NASGU>
%% Step1: obtain process reaction curve
Ts = Model.Ts;
% compute step response
[y t] = step(Model);
% remove offset from direct feed-through term
Offset = y(1);
y = y - Offset;

%% Step2: fit curve into a model
% compute K
K = evalfr(Model,double(Ts>0));
if K==0
    % if K is invalid, error out
    ctrlMsgUtils.error('Control:design:PIDTuning12');
elseif isinf(K)
    % integrating
    IsIntegrating = true;
    % get sign
    SignOfGain = sign(y(end));
    y = y*SignOfGain;
    % calculate maximum slope as K
    K = (y(end)-y(end-1))/(t(end)-t(end-1));
    % compute L
    L = (t(end-1)*y(end)-t(end)*y(end-1))/(y(end)-y(end-1));
else
    % non-integrating
    IsIntegrating = false;
    % get sign
    SignOfGain = sign(K);
    y = y*SignOfGain;
    % get K
    K = y(end);
    % calculate maximum slope
    [~,ind] = max(diff(y));
    slope = (y(ind+1)-y(ind))/(t(ind+1)-t(ind));
    if slope==0
        ctrlMsgUtils.error('Control:design:PIDTuning13');
    end
    % calculate alpha (Section 4.3, Astrom and Hagglund, 1994, 2nd Edition)
    alpha = slope*t(ind+1)-y(ind+1); 
    % calculate L (Section 4.3, Astrom and Hagglund, 1994, 2nd Edition)
    L = alpha/slope;
    % time conatant T from time L to 0.63K
    x0 = utIntersect(t,y,t,0.63*K*ones(length(t),1));
    if isempty(x0)
        ctrlMsgUtils.error('Control:design:PIDTuning11');
    end
    T = x0(1);
end

%% Step 3: generate Kc, Ti and Td
tol = 1e-3;
if IsIntegrating
    if K*L<tol
        % K/s: pole placement method
        damping = 0.707;
        w0 = 1;
        C = utPolePlacement(Type,K,[],damping,w0,IsIntegrating);
    else
        % K/s*exp(-L*s)
        switch Rule
            case 'amigool'                
                C = ut_AMIGO(Type,K,[],L,IsIntegrating);
            case 'chr'
                C = ut_CHRregulating(Type,K,[],L,IsIntegrating);
            case 'simc'
                C = ut_SIMC(Type,K,[],L,IsIntegrating);
            case 'znol'
                C = ut_ZieglerNichols(Type,K,[],L,IsIntegrating);
        end                
    end
else
    if L/T<tol
        % K/(T*s+1): pole placement method
        damping = 0.707;
        w0 = 10/2/damping/T;
        C = utPolePlacement(Type,K,T,damping,w0,IsIntegrating);
    else
        % K/(T*s+1)*exp(-L*s)
        switch Rule
            case 'amigool'                
                C = ut_AMIGO(Type,K,T,L,IsIntegrating);
            case 'chr'
                C = ut_CHRregulating(Type,K,T,L,IsIntegrating);
            case 'simc'
                C = ut_SIMC(Type,K,T,L,IsIntegrating);
            case 'znol'
                C = ut_ZieglerNichols(Type,K,T,L,IsIntegrating);
        end                
    end
end

%% post-processing
C = C*SignOfGain;
if Ts>0
    C = c2d(C,Ts);
end

function C = ut_ZieglerNichols(Type,K,T,L,IsIntegrating)
if IsIntegrating
    alpha = K*L;
else
    alpha = K*L/T;
end
switch Type
    case 'p' 
        C = pidstd(1/alpha);
    case 'pi' 
        C = pidstd(0.9/alpha,3*L);
    case 'pid'
        C = pidstd(1.2/alpha,2*L,0.5*L);
    case 'pidf'
        C = pidstd(1.2/alpha,2*L,0.5*L,10);
end

function C = ut_CHRregulating(Type,K,T,L,IsIntegrating)
if IsIntegrating
    alpha = K*L;
else
    alpha = K*L/T;
end
switch Type
    case 'p' 
        C = pidstd(0.3/alpha);
    case 'pi' 
        if ~IsIntegrating && L>T
            C = pidstd(0.2/K,0.2*L);
        else
            C = pidstd(0.6/alpha,4*L);
        end
    case 'pid'
        C = pidstd(0.95/alpha,2.38*L,0.42*L);
    case 'pidf'
        C = pidstd(0.95/alpha,2.38*L,0.42*L,10);
end

function C = ut_AMIGO(Type,K,T,L,IsIntegrating)
if IsIntegrating
    switch Type
        case 'p' 
            C = pidstd(0.3/K/L);
        case 'pi' 
            C = pidstd(0.35/K/L,13.4*L);
        case 'pid'
            C = pidstd(0.45/K,8*L,0.5*L);
        case 'pidf'
            C = pidstd(0.45/K,8*L,0.5*L,10);
    end
else
    switch Type
        case 'p' 
            C = pidstd(0.3/(K*L/T));
        case 'pi' 
            C = pidstd(0.15/K+(0.35-L*T/(L+T)^2)*T/K/L,0.35*L+13*L*T^2/(T^2+12*L*T+7*L^2));
        case 'pid'
            C = pidstd(1/K*(0.2+0.45*T/L),(0.4*L+0.8*T)/(L+0.1*T)*L,0.5*L*T/(0.3*L+T));
        case 'pidf'
            C = pidstd(1/K*(0.2+0.45*T/L),(0.4*L+0.8*T)/(L+0.1*T)*L,0.5*L*T/(0.3*L+T),10);
    end
end

function C = ut_SIMC(Type,K,T,L,IsIntegrating)
if IsIntegrating
    switch Type
        case 'p' 
            C = pidstd(0.3/(K/L));
        case 'pi' 
            C = pidstd(1/2/K/L/L,8*L);
        case 'pid'
            C = pidstd(pidstd(1/2/K/L/L,8*L)*tf([L/2 1],1));
        case 'pidf'
            C = pidstd(pidstd(1/2/K/L/L,8*L)*tf([L/2 1],[L/4,1]));
    end
else
    switch Type
        case 'p' 
            C = pidstd(0.3/(K*L/T));
        case 'pi' 
            C = pidstd(T/2/K/L,min(T,8*L));
        case 'pid'
            C = pidstd(pidstd(T/2/K/L,min(T,8*L))*tf([L/2 1],1));
        case 'pidf'
            C = pidstd(pidstd(T/2/K/L,min(T,8*L))*tf([L/2 1],[L/4,1]));
    end
end

function C = utPolePlacement(Type,K,T,damping,w0,IsIntegrating)
switch Type
    case 'p'
        Kp = 5/K; 
        C = pidstd(Kp);
    case {'pi','pid','pidn'}
        if IsIntegrating
            Kp = 2*damping*w0/K;
            Ti = 2*damping/w0;
        else
            Kp = (2*damping*w0*T-1)/K;
            Ti = (2*damping*w0*T-1)/(w0*w0*T);
        end
        C = pidstd(Kp,Ti);
end                
