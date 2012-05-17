function S = CZPK(this,blockname) 
% CZPK  This is the configuration function for the continuous 
% zero pole gain.
%

% Author(s): John W. Glass 18-Jul-2005
%   Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2007/11/09 21:03:20 $
                          
% Get the run-time object for this block
r = get_param(blockname,'RunTimeObject');

% Set up the tunable parameters
if numel(find(r.DialogPrm(1).Dimensions ~= 0))
    zeros = r.DialogPrm(1).data;
else
    zeros = [];
end

TunableParameters(1) = struct('Name','Zeros',...
                              'Value',zeros,...
                              'Tunable','on');

if numel(find(r.DialogPrm(2).Dimensions ~= 0))
    poles = r.DialogPrm(2).data;
else
    poles = [];
end
TunableParameters(2) = struct('Name','Poles',...
                              'Value',poles,...
                              'Tunable','on');

if numel(find(r.DialogPrm(3).Dimensions ~= 0))
    gain = r.DialogPrm(3).data;
else
    gain = [];
end
TunableParameters(3) = struct('Name','Gain',...
                              'Value',gain,...
                              'Tunable','on');

% Set up the evaluation function
EvalFcn = @LocalEvalFcn;

% Set up the inverse function
InvFcn = @LocalInvFcn;

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

% Check input sizes
if (~isvector(S(1).Value) && ~isempty(S(1).Value)) ||...
            (~isvector(S(2).Value) && ~isempty(S(2).Value))
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKPoleZero')
elseif ~isscalar(S(3).Value)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKGain')
end

% Computed the tune component
C = zpk(S(1).Value,S(2).Value,S(3).Value);
% The fixed element is a gain of 1
Cfixed = zpk([],[],1);

% ------------------------------------------------------------------------
function S = LocalInvFcn(S,z,p,k)

% Compute the inverse
S(1).Value = z;
S(2).Value = p;
S(3).Value = k;

