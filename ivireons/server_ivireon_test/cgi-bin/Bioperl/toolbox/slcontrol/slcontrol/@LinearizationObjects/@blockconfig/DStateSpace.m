function S = DStateSpace(this,blockname) 
% DSTATESPACE  This is the configuration function for the discrete 
% state space block
%

% Author(s): John W. Glass 18-Jul-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:42:44 $
                          
%% Get the run-time object for this block
r = get_param(blockname,'RunTimeObject');

%% Set up the tunable parameters
if prod(r.DialogPrm(1).Dimensions) == 0
    TunableParameters(1) = struct('Name','A',...
        'Value',[],...
        'Tunable','on');
else
    TunableParameters(1) = struct('Name','A',...
        'Value',r.DialogPrm(1).data,...
        'Tunable','on');
end
if prod(r.DialogPrm(2).Dimensions) == 0
    TunableParameters(2) = struct('Name','B',...
        'Value',[],...
        'Tunable','on');
else
    TunableParameters(2) = struct('Name','B',...
        'Value',r.DialogPrm(2).data,...
        'Tunable','on');
end
if prod(r.DialogPrm(3).Dimensions) == 0
    TunableParameters(3) = struct('Name','C',...
        'Value',[],...
        'Tunable','on');
else
    TunableParameters(3) = struct('Name','C',...
        'Value',r.DialogPrm(3).data,...
        'Tunable','on');
end
if prod(r.DialogPrm(4).Dimensions) == 0
    TunableParameters(4) = struct('Name','D',...
        'Value',[],...
        'Tunable','on');
else
    TunableParameters(4) = struct('Name','D',...
        'Value',r.DialogPrm(4).data,...
        'Tunable','on');
end

TunableParameters(5) = struct('Name','SampleTime',...
                              'Value',r.SampleTimes(1),...
                              'Tunable','off');    
                          
%% Set up the evaluation function
EvalFcn = @LocalEvalFcn;

%% Set up the inverse function
InvFcn = @LocalInvFcn;

%% Create the constraints
Constraints = struct('MaxZeros',inf,'MaxPoles',inf,...
                     'isStaticGainTunable',true,...
                     'allowImproper',false);

S = struct('TunableParameters',TunableParameters,...
           'EvalFcn',EvalFcn,...
           'InvFcn',InvFcn,...
           'Constraints',Constraints,...
           'Inport',1,...
           'Outport',1);

%% ------------------------------------------------------------------------
function [C,Cfixed] = LocalEvalFcn(S)

% Computed the tune component
C = zpk(ss(S(1).Value,S(2).Value,S(3).Value,S(4).Value,S(5).Value));
% The fixed element is a gain of 1
Cfixed = zpk([],[],1,S(5).Value);

%% ------------------------------------------------------------------------
function S = LocalInvFcn(S,z,p,k)

% Computed the inverse
[A,B,C,D]=ssdata(zpk(z,p,k,S(5).Value));
S(1).Value = A;
S(2).Value = B;
S(3).Value = C;
S(4).Value = D;