function S = DTFFirstOrder(this,blockname,TunableParameters)  
% DTFFIRSTORDER  Configuration function for the first order discrete block
%
 
% Author(s): John W. Glass 21-Oct-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/10/15 23:31:08 $

% Get the first parameter which is the time constant
TunableParameters = TunableParameters(1);

% Get the sample time
r = get_param(sprintf('%s/UD',blockname),'RunTimeObject');
ts = r.SampleTimes(1);

% Set up the evaluation function
EvalFcn = {@LocalEvalFcn,ts};

% Set up the inverse function
InvFcn = {@LocalInvFcn,ts};

% Create the constraints
Constraints = struct('MaxZeros',0,'MaxPoles',1,'isStaticGainTunable',false);

S = struct('TunableParameters',TunableParameters,...
           'EvalFcn',{EvalFcn},...
           'InvFcn',{InvFcn},...
           'Constraints',Constraints,...
           'Inport',1,...
           'Outport',1);
       
%% ------------------------------------------------------------------------
function [C,Cfixed] = LocalEvalFcn(S,ts)

% Check input sizes
Tau = S(1).Value;
if ~isscalar(Tau)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidDFirstOrderTimeConstant')
end

% Set the tunable component
C = zpk(0,Tau,1-Tau,ts);

% Set the fixed component
Cfixed = zpk([],[],1,ts);

%% ------------------------------------------------------------------------
function S = LocalInvFcn(S,z,p,k,ts)

S(1).Value = p;