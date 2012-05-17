function S = DTransferFcnIO(this,blockname,TunableParameters) 
% DTRANSFERFCNIO  This is the configuration function for the discrete 
% transfer function block with initial outputs in Simulink Extras library
%

% Author(s): Erman Korkut 29-Apr-2008
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:34:16 $
                          
                 
% Set up the evaluation function
EvalFcn = @LocalEvalFcn;

% Set up the inverse function
InvFcn = @LocalInvFcn;


FilteredTunableParameters(1) = struct('Name','N',...
                              'Value',TunableParameters(strcmp('N',{TunableParameters.Name})).Value,...
                              'Tunable','on');

FilteredTunableParameters(2) = struct('Name','D',...
                              'Value',TunableParameters(strcmp('D',{TunableParameters.Name})).Value,...
                              'Tunable','on');
                          
FilteredTunableParameters(3) = struct('Name','TS',...
                              'Value',TunableParameters(strcmp('TS',{TunableParameters.Name})).Value,...
                              'Tunable','off');

FilteredTunableParameters(4) = struct('Name','U0',...
                              'Value',TunableParameters(strcmp('X0',{TunableParameters.Name})).Value,...
                              'Tunable','off');
                          
FilteredTunableParameters(5) = struct('Name','Y0',...
                              'Value',TunableParameters(strcmp('X0',{TunableParameters.Name})).Value,...
                              'Tunable','off');



% Create the constraints
Constraints = struct('MaxZeros',inf,'MaxPoles',inf,'isStaticGainTunable',true);

S = struct('TunableParameters',FilteredTunableParameters,...
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
