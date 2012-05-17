function S = CStateSpaceIO(this,blockname,TunableParameters) 
% CSTATESPACEIO  This is the configuration function for the continuous 
% state space block with initial outputs
%

% Author(s): Erman Korkut Oct-16-2008
% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:34:10 $
                          
%% Get the run-time object for this block
r = get_param(blockname,'RunTimeObject');

%% Set up the tunable parameters
TunableParameters(1) = struct('Name','A',...
                              'Value',TunableParameters(strcmp('A',{TunableParameters.Name})).Value,...
                              'Tunable','on');

TunableParameters(2) = struct('Name','B',...
                              'Value',TunableParameters(strcmp('B',{TunableParameters.Name})).Value,...
                              'Tunable','on');
                          
TunableParameters(3) = struct('Name','C',...
                              'Value',TunableParameters(strcmp('C',{TunableParameters.Name})).Value,...
                              'Tunable','on');

TunableParameters(4) = struct('Name','D',...
                              'Value',TunableParameters(strcmp('D',{TunableParameters.Name})).Value,...
                              'Tunable','on'); 

TunableParameters(5) = struct('Name','U0',...
                              'Value',TunableParameters(strcmp('U0',{TunableParameters.Name})).Value,...
                              'Tunable','off');

TunableParameters(6) = struct('Name','Y0',...
                              'Value',TunableParameters(strcmp('Y0',{TunableParameters.Name})).Value,...
                              'Tunable','off');

TunableParameters(7) = struct('Name','X0',...
                              'Value',TunableParameters(strcmp('X0',{TunableParameters.Name})).Value,...
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
       
function [C,Cfixed] = LocalEvalFcn(S)

% Computed the tune component
C = zpk(ss(S(1).Value,S(2).Value,S(3).Value,S(4).Value));
% The fixed element is a gain of 1
Cfixed = zpk([],[],1);

%% ------------------------------------------------------------------------
function S = LocalInvFcn(S,z,p,k)

% Computed the inverse
[A,B,C,D]=ssdata(zpk(z,p,k));
S(1).Value = A;
S(2).Value = B;
S(3).Value = C;
S(4).Value = D;

