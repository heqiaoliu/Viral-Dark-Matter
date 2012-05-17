function S = MDLTIBlock(this,blockname,TunableParameters)
% MDLTIBLOCK  This is the configuration function for discretized the control toolbox lti
% block.
%

% Author(s): Erman Korkut 29-Apr-2008
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:34:20 $
                          

%% Error check against the method to discretize
method = TunableParameters(strcmp('method',{TunableParameters.Name})).Value;
% Reject to do control design if the method is foh (D2C does not support it)
if strcmp(method,'foh')
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidDiscretizationMethod');
end
%% Create the constraints
% If the method is 'zoh' or 'imp', do not allow improper controllers(C2D requirement)
if strcmp(method,'zoh') || strcmp(method,'imp')
    Constraints = struct('MaxZeros',inf,'MaxPoles',inf,'isStaticGainTunable',true,'allowImproper',false);
else
    Constraints = struct('MaxZeros',inf,'MaxPoles',inf,'isStaticGainTunable',true);
end


%% Create the Tunable Parameters
FilteredTunableParameters(1) = struct('Name','sysc',...
                              'Value',TunableParameters(strcmp('sysc',{TunableParameters.Name})).Value,...
                              'Tunable','on');                     
                          
FilteredTunableParameters(2) = struct('Name','SampleTime',...
                              'Value',TunableParameters(strcmp('SampleTime',{TunableParameters.Name})).Value,...
                              'Tunable','off');

FilteredTunableParameters(3) = struct('Name','method',...
                          'Value',method,...
                          'Tunable','off'); 
                      
FilteredTunableParameters(4) = struct('Name','Wc',...
                          'Value',TunableParameters(strcmp('Wc',{TunableParameters.Name})).Value,...
                          'Tunable','off'); 

%% Get the class of the system
class_sys = class(TunableParameters(strcmp('sysc',{TunableParameters.Name})).Value);
                

%% Set up the evaluation function
EvalFcn = @LocalEvalFcn;

%% Set up the inverse function
InvFcn = @(S,Z,P,K) LocalInvFcn(S,Z,P,K,class_sys);

S = struct('TunableParameters',FilteredTunableParameters,...
           'EvalFcn',EvalFcn,...
           'InvFcn',InvFcn,...
           'Constraints',Constraints,...
           'Inport',1,...
           'Outport',1);

%% ------------------------------------------------------------------------
function [C,Cfixed] = LocalEvalFcn(S)

%% Computed the tune component
sys = S(1).Value;
ts = S(2).Value;
method = S(3).Value;
if strcmp(method,'prewarp')
  WcRad = S(4).Value*2*pi;
  C = c2d(sys,ts,method,WcRad);
else
  C = c2d(sys,ts,method);
end
%% Convert to ZPK
C = zpk(C);
%% The fixed element is a gain of 1
Cfixed = zpk([],[],1,ts);

%% ------------------------------------------------------------------------
function TunableParameters_out = LocalInvFcn(TunableParameters_in,z,p,k,class_sys)

% Initialize parameters
TunableParameters_out = TunableParameters_in;

sysd = zpk(z,p,k,TunableParameters_in(2).Value);
if strcmp(TunableParameters_in(3).Value,'prewarp')
  WcRad = TunableParameters_in(4).Value*2*pi;
  sys = d2c(sysd,TunableParameters_in(3).Value,WcRad);
else
  sys = d2c(sysd,TunableParameters_in(3).Value);
end

%% Write the parameter set
switch class_sys
    case 'ss'
        TunableParameters_out(1).Value = ss(sys);
    case 'tf'
        TunableParameters_out(1).Value = tf(sys);
    case 'zpk'
        TunableParameters_out(1).Value = sys;
end
