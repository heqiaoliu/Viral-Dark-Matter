function S = PIDApproxBlock(this,blockname,TunableParameters) 
% PIDApproxBlock  This is the configuration function for the PID with 
% with approximate derivative block.
%

% Author(s): John W. Glass 18-Jul-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2009/05/23 08:19:45 $
                        
% Set up the evaluation function
EvalFcn = @LocalEvalFcn;

% Set up the inverse function
InvFcn = @LocalInvFcn;

% Create the constraints
Constraints = struct('MaxZeros',2,'MaxPoles',2,'isStaticGainTunable',true);

S = struct('TunableParameters',TunableParameters,...
           'EvalFcn',EvalFcn,...
           'InvFcn',InvFcn,...
           'Constraints',Constraints,...
           'Inport',1,...
           'Outport',1);
       
%% ------------------------------------------------------------------------
function [C,Cfixed] = LocalEvalFcn(S)

P = S(1).Value;
I = S(2).Value;
D = S(3).Value;
N = S(4).Value;

% Check input sizes
if ~localparamcheck(P) || ~localparamcheck(I) || ~localparamcheck(D) || ~isreal(N) || ~isscalar(N)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPID')
end

if D == 0
    if P == 0
        C = zpk([],[],I);
        %% Set the fixed component
        Cfixed = zpk([],0,1);
    elseif I == 0
        C = zpk([],[],P);
        %% Set the fixed component
        Cfixed = zpk([],[],1);
    else
        C = zpk(-I/P,[],P);
        Cfixed = zpk([],0,1);
    end
elseif I == 0
    if N == 0
        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
    elseif P == 0
        C = zpk(0,-N,D*N);
    elseif isinf(N)
        C = zpk(-P/D,[],D);
    else
        C = zpk(-P*N/(P+D*N),-N,P+D*N);
    end
    %% Set the fixed component
    Cfixed = zpk([],[],1);
else
    if isinf(N)
        C = zpk(tf([D P I],1));
    elseif N == 0
        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
    else
        C = zpk(tf([(D*N+P) (P*N+I) I*N], [1 N]));
    end
    %% Set the fixed component
    Cfixed = zpk([],0,1);
end

%% ------------------------------------------------------------------------
function S = LocalInvFcn(S,z,p,k)

% Remove free integrators added by the automated tuning feature if the
%  compensator does not currently have a fixed component.  If there is a
%  fixed component then error out since the derivative time constant cannot
%  be zero.
if any(p == 0) 
    if length(p(p == 0))==1
        p(p == 0) = [];        
        isintegrating = true;
    else
        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
    end
else
    isintegrating = false;
end

%% There are nine configurations of the PID controller
% Case 1: PIDN are non-zero (Handles P == 0)
% G(s) = P + I/s + Ds/(s/N+1)
% 2 zeros, 1 poles, free integrator
%
% Case 2: PID are non-zero N is inf (Handles P == 0)
% G(s) = P + I/s + Ds
% 2 zeros, free integrator
%
% Case 3: PI are non-zero, D is zero, N can be anything
% G(s) = P + I/s
% 1 zero, free integrator
%
% Case 4: PD are non-zero, I is zero, N finite (Handles P == 0)
% G(s) = P + Ds/(s/N+1)
% 1 zero, 1 pole
%
% Case 5: PD are non-zero, I is zero, N infinite (Handles P == 0)
% G(s) = P + Ds
% 1 zero
%
% Case 6: D is non-zero, PI are zero, N finite
% G(s) = Ds/(s/N+1)
% 1 zero, 1 pole
%
% Case 7: D is non-zero, PI are zero, N infinite (Handles P == 0)
% G(s) = Ds
% 1 zero
%
% Case 8: P is non-zero, ID are zero, N can be anything 
%
% Case 9: I is non-zero, PD is zero, N can be anything
% G(s) = I/s
% 0 zeros, free integrator

%% Compute the inverse function
switch numel(z)
    case 0
        %% Determine if the compensator is fixed
        if isintegrating % Case 9
            S(1).Value = 0;
            S(2).Value = k;
        else % Case 8
            S(1).Value = k;
            S(2).Value = 0;
        end
        S(3).Value = 0;
    case 1
        if z == 0 
            if numel(p) == 0  % Case 6             
                S(4).Value = inf;
                S(1).Value = 0;
                S(2).Value = 0;
                S(3).Value = k;
            else % Case 7
                S(4).Value = -p;
                S(1).Value = 0;
                S(2).Value = 0;
                S(3).Value = k/(-p);                
            end
        elseif numel(p) == 1 % Case 4
            S(4).Value = -p;
            S(1).Value = -z*k/(-p);
            S(2).Value = 0;
            S(3).Value = (k-S(1).Value)/(-p);
        else
            %% Determine if the compensator is fixed
            if isintegrating % Case 3
                S(3).Value = 0;
                S(1).Value = k;
                S(2).Value = -k*z;
            else % Case 5
                S(1).Value = -k*z;
                S(3).Value = k;
                S(2).Value = 0;
                S(4).Value = inf;
            end
        end
    case 2
        if isempty(p) % Case 2
            S = LocalPIDNoFilter(S,z,p,k);
        else % Case 1
            S = LocalPIDWithFilter(S,z,p,k);
        end
end

%% ------------------------------------------------------------------------
% LocalPIDWithFilter Compute the gains for the case where the derivative term
% is not filtered.
function S = LocalPIDWithFilter(S,z,p,k)

% Set the Derivative filter time constant
N = -p;
S(4).Value = N;

% Compute the Integrator gain I = k*z1*z2/N
I = k*real(z(1)*z(2))/N;
S(2).Value = I;

% Compute the Proportional gain P = -(k*(z1+z2)+I)/N
P = -(k*(real(z(1)+z(2)))+I)/N;
S(1).Value = P;

% Compute the Derivative gain D = -(P/N)+k
D = (k-P)/N;
S(3).Value = D;
            
%% ------------------------------------------------------------------------
% LocalPIDNoFilter Compute the gains for the case where the derivative term
% is not filtered.
function S = LocalPIDNoFilter(S,z,p,k)

% Set the Derivative filter time constant
N = inf;
S(4).Value = N;

% Compute the Derivative gain D = k
D = k;
S(3).Value = D;

% Compute the Integrator gain I = k*z1*z2
I = k*real(z(1)*z(2));
S(2).Value = I;

% Compute the Proportional gain P = -(k*(z1+z2)+I)
P = -k*(real(z(1)+z(2)));
S(1).Value = P;

%% ------------------------------------------------------------------------
function val = localparamcheck(param)

if isscalar(param) && isfinite(param) && isreal(param)
    val = true;
else
    val = false;
end