function S = DTFRealZero(this,blockname,TunableParameters)  
% DTFREALZERO  Configuration function for the first order discrete block
% with a real zero.
%
 
% Author(s): John W. Glass 21-Oct-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/10/15 23:31:10 $

% Get the first parameter which is the time constant
TunableParameters = TunableParameters(1);

% Get the sample time
r = get_param(sprintf('%s/Delay Input',blockname),'RunTimeObject');
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

Tau_z = S(1).Value;

% Check input sizes
if ~isscalar(Tau_z)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidDZeroTimeConstant')
end

% Set the tunable component
C = zpk(Tau_z,[],1,ts);

% Set the fixed component
Cfixed = zpk([],0,1,ts);

%% ------------------------------------------------------------------------
function S = LocalInvFcn(S,z,p,k,ts)

S(1).Value = z;