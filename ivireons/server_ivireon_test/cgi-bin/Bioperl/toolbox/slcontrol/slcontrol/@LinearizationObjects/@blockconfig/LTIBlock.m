function S = LTIBlock(~,blockname,~)
% LTIBLOCK  This is the configuration function for the control toolbox lti
% block.
%

% Author(s): John W. Glass 18-Jul-2005
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/06/11 16:08:54 $
                          
% Get the parameters from the mask workspace
MaskWSVariables = get_param(blockname,'MaskWSVariables');

% Get the parameter names so to filter the parameters
MaskWSVariablesName = {MaskWSVariables.Name};

% Get the evaluated value for the block
ind_sys = strcmp('sys',MaskWSVariablesName);
sys = MaskWSVariables(ind_sys).Value;

if hasdelay(sys)
    ctrlMsgUtils.error('Slcontrol:controldesign:TunedLTIBlockWithDelay',blockname);
end

% Create the Tunable Parameters
TunableParameters = struct('Name','sys','Value',sys,'Tunable','on');

% Get the class of the system
class_sys = class(sys);

% Set up the evaluation function
EvalFcn = @LocalEvalFcn;

% Set up the inverse function
InvFcn = @(S,Z,P,K) LocalInvFcn(S,Z,P,K,sys.Ts,class_sys);

% Create the constraints
Constraints = struct('MaxZeros',inf,'MaxPoles',inf,'isStaticGainTunable',true);

S = struct('TunableParameters',TunableParameters,...
           'EvalFcn',EvalFcn,...
           'InvFcn',InvFcn,...
           'Constraints',Constraints,...
           'Inport',1,...
           'Outport',1);

%% ------------------------------------------------------------------------
function [C,Cfixed] = LocalEvalFcn(S)

% Computed the tune component
C = zpk(S(1).Value);
% The fixed element is a gain of 1
Cfixed = zpk([],[],1);

%% ------------------------------------------------------------------------
function S = LocalInvFcn(S,z,p,k,Ts,class_sys)

sys = zpk(z,p,k,Ts);
% Write the parameter set
switch class_sys
    case 'ss'
        S(1).Value = ss(sys);
    case 'tf'
        S(1).Value = tf(sys);
    case 'zpk'
        S(1).Value = sys;
end
