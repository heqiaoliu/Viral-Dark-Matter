function S = scdleadexample(blockname,TunableParameters) 
% SCDLEADEXAMPLE  Configuration function for the lead-lag controller demo.
%
% SCDLEADEXAMPLE creates the configuration structure S which is used by
% Simulink Control Design to register a masked subsystem for compensator
% design.  The configuration function is called with the name of the block,
% blockname and a structure vector containing the evaluated block mask
% variables.

% Author(s): John W. Glass 18-Jul-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2007/11/09 21:03:58 $
                         
% Set up the evaluation function.  This is the function that converts the
% block dialog parameters in TunableParameters to a zero/pole/gain form
% for control design.
EvalFcn = @LocalEvalFcn;

% Set up the inverse function.  This is the function that converts the
% zero/pole/gain form of the compensator to its corresponding block
% parameters.
InvFcn = @LocalInvFcn;

% Create the constraints.  In this case the compensator can have a maximum
% of 1 pole and 1 zero.  The static gain is freely tunable.
Constraints = struct('MaxZeros',1,'MaxPoles',1,...
                     'isStaticGainTunable',true);

% Register the parameters 
S = struct('TunableParameters',TunableParameters,...
           'EvalFcn',EvalFcn,...
           'InvFcn',InvFcn,...
           'Constraints',Constraints,...
           'Inport',1,...
           'Outport',1);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalEvalFcn computes the tunable component C and the fixed component
% Cfixed of the compensator.  
function [C,Cfixed] = LocalEvalFcn(TunableParameters)

% Specify the zero/pole/gain data given the parameter values 
k = TunableParameters(1).Value;
zero = TunableParameters(2).Value;
pole = TunableParameters(3).Value;

% Check input sizes
if ~isscalar(k) || ~isscalar(zero) || ~isscalar(pole)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidLeadLagParameter')
end

% Check for the case where either the pole or zero parameters are zero
if (k == 0) || (zero == 0) || (pole == 0)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidLeadLagParameter')
end

% Compute the tune component and handle the cases where there are no
% poles or zeros.  If a zero or pole is empty it will have a value of
% infinity.
if ~isempty(pole) && ~isempty(zero) && (isfinite(pole) && isfinite(zero))
    C = zpk(-zero,-pole,k*pole/zero);
elseif isempty(zero) && ~isempty(pole) || (isfinite(pole) && ~isfinite(zero))
    C = zpk([],-pole,k*pole);
elseif isempty(pole) && ~isempty(zero) || (~isfinite(pole) && isfinite(zero))
    C = zpk(-zero,[],k/zero);
else
    C = zpk([],[],k);
end

% The fixed element is a gain of 1
Cfixed = zpk([],[],1);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalEvalFcn computes the block dialog parameters given pole-zero-gain 
% values. 
function TunableParameters_out = LocalInvFcn(TunableParameters_in,z,p,k)

% Initialize the output parameters
TunableParameters_out = TunableParameters_in;

% Compute the inverse and handle the cases where the poles and zeros are
% deleted.
if ~isempty(z) && ~isempty(p)
    %% 1 zero and 1 pole
    TunableParameters_out(1).Value = k*z/p;
    TunableParameters_out(2).Value = -z;
    TunableParameters_out(3).Value = -p;
elseif isempty(z) && ~isempty(p)
    %% 1 pole and no zero.  Assign a value of inf for the zero.
    TunableParameters_out(1).Value = -k/p;
    TunableParameters_out(2).Value = inf;
    TunableParameters_out(3).Value = -p;
elseif ~isempty(z) && isempty(p)
    %% 1 zero and no pole.  Assign a value of inf for the pole.
    TunableParameters_out(1).Value = -k*z;
    TunableParameters_out(2).Value = -z;
    TunableParameters_out(3).Value = inf;
else
    %% No zeros or poles.  In this case the block becomes a gain.
    TunableParameters_out(1).Value = k;
    TunableParameters_out(2).Value = inf;
    TunableParameters_out(3).Value = inf;
end
    