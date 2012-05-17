function S = DTransferFcn(this,blockname) 
% DTRANSFERFCN  This is the configuration function for the discrete 
% transfer function block
%

% Author(s): John W. Glass 18-Jul-2005
%   Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2007/11/09 21:03:21 $
                          
% Get the run-time object for this block
r = get_param(blockname,'RunTimeObject');

% Set up the tunable parameters
TunableParameters(1) = struct('Name','Numerator',...
                              'Value',r.DialogPrm(1).data,...
                              'Tunable','on');

TunableParameters(2) = struct('Name','Denominator',...
                              'Value',r.DialogPrm(2).data,...
                              'Tunable','on');
                          
TunableParameters(3) = struct('Name','SampleTime',...
                              'Value',r.SampleTimes(1),...
                              'Tunable','off');                          

% Set up the evaluation function
EvalFcn = @LocalEvalFcn;

% Set up the inverse function
InvFcn = @LocalInvFcn;

% Create the constraints
Constraints = struct('MaxZeros',inf,'MaxPoles',inf,'isStaticGainTunable',true);

S = struct('TunableParameters',TunableParameters,...
           'EvalFcn',{EvalFcn},...
           'InvFcn',{InvFcn},...
           'Constraints',Constraints,...
           'Inport',1,...
           'Outport',1);

%% ------------------------------------------------------------------------
function [C,Cfixed] = LocalEvalFcn(S)

% Check input sizes
if ~isvector(S(1).Value) || ~isvector(S(2).Value)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidDTFNumDen')
end

% Computed the tune component
C = zpk(tf(S(1).Value,S(2).Value,S(3).Value));
% The fixed element is a gain of 1
Cfixed = zpk([],[],1,S(3).Value);

%% ------------------------------------------------------------------------
function S = LocalInvFcn(S,z,p,k)

% Computed the inverse
if k == 0
    S(1).Value = 0;
    den = poly(p);
else
    [num,den]=tfdata(zpk(z,p,k,S(3).Value),'v');
    % Find the hard zeros leading the numerator
    ind = find(num,1);
    S(1).Value = num(ind:end);
end

S(2).Value = den;
