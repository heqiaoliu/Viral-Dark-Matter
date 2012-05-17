function S = PIDBlock(this,blockname,TunableParameters) 
% PIDApproxBlock  This is the configuration function for the PID with 
% with approximate derivative block.
%
 
% Author(s): John W. Glass 18-Jul-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2007/10/15 23:31:15 $
                        
% Set up the evaluation function
EvalFcn = @LocalEvalFcn;

% Set up the inverse function
InvFcn = @LocalInvFcn;

% Create the constraints
Constraints = struct('MaxZeros',2,'MaxPoles',1,'isStaticGainTunable',true);

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

% Check input sizes
if ~localparamcheck(P) || ~localparamcheck(I) || ~localparamcheck(D)
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
        %% Set the fixed component
        Cfixed = zpk([],0,1);
    end
elseif I == 0
    C = zpk(-P/D,[],D);
    %% Set the fixed component
    Cfixed = zpk([],[],1);
else
    C = zpk(tf([D P I], 1));
    %% Set the fixed component
    Cfixed = zpk([],0,1);
end

%% ------------------------------------------------------------------------
function S = LocalInvFcn(S,z,p,k)

%% Remove free integrators added by the automated tuning feature if the
%  compensator has a fixed component. 
if any(p == 0) 
    if length(p(p == 0))==1
        p(p == 0) = [];        
        isintegrating = true;
    else
        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDPole')
    end
else
    isintegrating = false;
end

%% If there are any poles left error out
if ~isempty(p)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDPole')
end

%% There are four configurations of the PID controller
% Case 1: PID are non-zero (Handles P == 0)
% G(s) = P + I/s + Ds
% 2 zeros, 1 poles, free integrator
%
% Case 2: PI are non-zero, D is zero
% G(s) = P + I/s
% 1 zero, free integrator
%
% Case 3: PD are non-zero, I is zero
% G(s) = P + Ds
% 1 zero, 1 pole
%
% Case 4: P is non-zero, ID are zero

%% Compute the inverse
if numel(z) == 1
    if isintegrating
        S(3).Value = 0;
        S(1).Value = k;
        S(2).Value = -k*(real(z));
    else
        S(3).Value = k;
        S(1).Value = -k*real(z);
        S(2).Value = 0;
    end
elseif numel(z) == 2 % Case 1
    S = LocalPIDNoFilter(S,z,p,k);
else
    if isintegrating
        S(3).Value = 0;
        S(1).Value = 0;
        S(2).Value = k;
    else
        S(3).Value = 0;
        S(1).Value = k;
        S(2).Value = 0;
    end
end
            
%% ------------------------------------------------------------------------
% LocalPIDNoFilter Compute the gains for the case where the derivative term
% is not filtered.
function S = LocalPIDNoFilter(S,z,p,k)

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
