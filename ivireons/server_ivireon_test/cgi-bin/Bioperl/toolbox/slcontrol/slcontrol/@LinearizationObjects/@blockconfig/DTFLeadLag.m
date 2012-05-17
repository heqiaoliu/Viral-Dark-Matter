function S = DTFLeadLag(this,blockname,TunableParameters)   
% DTFLEADLAG  Configuration function for the first order discrete block
%
 
% Author(s): John W. Glass 21-Oct-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/10/15 23:31:09 $

% Get the first two parameters which are the time constant
TunableParameters = TunableParameters(1:2);

% Get the sample time
r = get_param(sprintf('%s/Delay Output',blockname),'RunTimeObject');
ts = r.SampleTimes(1);

% Set up the evaluation function
EvalFcn = {@LocalEvalFcn,ts};

% Set up the inverse function
InvFcn = {@LocalInvFcn,ts};

% Create the constraints
Constraints = struct('MaxZeros',1,'MaxPoles',1,'isStaticGainTunable',false);

S = struct('TunableParameters',TunableParameters,...
           'EvalFcn',{EvalFcn},...
           'InvFcn',{InvFcn},...
           'Constraints',Constraints,...
           'Inport',1,...
           'Outport',1);
       
%% ------------------------------------------------------------------------
function [C,Cfixed] = LocalEvalFcn(S,ts)

Tau_z = S(2).Value;
Tau_p = S(1).Value;

% Check input sizes
if ~isscalar(Tau_z) || ~isscalar(Tau_p)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidDLeadLagPoleZero')
end

% Set the tunable component
C = zpk(Tau_z,Tau_p,1,ts);

% Set the fixed component
Cfixed = zpk([],[],1,ts);

%% ------------------------------------------------------------------------
function S = LocalInvFcn(S,z,p,k,ts)

S(1).Value = p;
S(2).Value = z;