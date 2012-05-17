function S = GainBlock(this,blockname) 
% GAINBLOCK  This is the configuration function for the gain block
%
 
% Author(s): John W. Glass 18-Jul-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/10/15 23:31:13 $
    
% Get the run-time object for this block
r = get_param(blockname,'RunTimeObject');

% Set up the tunable parameters
TunableParameters = struct('Name','Gain',...
                             'Value',r.RuntimePrm(1).data,...
                             'Tunable','on');

% Get the sample time
r = get_param(blockname,'RunTimeObject');
ts = r.SampleTimes(1);                         

% Set up the evaluation function
EvalFcn = {@LocalEvalFcn,ts};

% Set up the inverse function
InvFcn = @LocalInvFcn;

% Create the constraints
Constraints = struct('MaxZeros',0,'MaxPoles',0,'isStaticGainTunable',true);

S = struct('TunableParameters',TunableParameters,...
           'EvalFcn',{EvalFcn},...
           'InvFcn',InvFcn,...
           'Constraints',Constraints,...
           'Inport',1,...
           'Outport',1);
       
%% ------------------------------------------------------------------------
function [C,Cfixed] = LocalEvalFcn(S,ts)

% Check input sizes
if ~isscalar(S(1).Value)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidGain')
end

% Computed the tune component
C = zpk([],[],S.Value,ts);
% The fixed element is a gain of 1
Cfixed = zpk([],[],1,ts);

%% ------------------------------------------------------------------------
function S = LocalInvFcn(S,z,p,k)

% Computed the tune component
S.Value = k;
