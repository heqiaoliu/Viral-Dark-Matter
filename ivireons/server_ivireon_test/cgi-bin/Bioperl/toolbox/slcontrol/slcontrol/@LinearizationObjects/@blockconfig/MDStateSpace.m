function S = MDStateSpace(this,blockname,TunableParameters)
% MDSTATESPACE  This is the configuration function for the discretized
% statespace block.
%

% Author(s): Erman Korkut 22-Apr-2008
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:34:21 $

% Setup evaluation and inverse function
EvalFcn = @LocalEvalFcn;
InvFcn = @LocalInvFcn;

% Setup constraints
Constraints = struct('MaxZeros',inf,'MaxPoles',inf,...
                     'isStaticGainTunable',true,...
                     'allowImproper',false);

method = TunableParameters(strcmp('method',{TunableParameters.Name})).Value;
% Reject to do control design if the method is foh (D2C does not support it)
if strcmp(method,'foh')
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidDiscretizationMethod');
end

        
FilteredTunableParameters(1) = struct('Name','A',...
                              'Value',TunableParameters(strcmp('A',{TunableParameters.Name})).Value,...
                              'Tunable','on');

FilteredTunableParameters(2) = struct('Name','B',...
                              'Value',TunableParameters(strcmp('B',{TunableParameters.Name})).Value,...
                              'Tunable','on');
                          
FilteredTunableParameters(3) = struct('Name','C',...
                              'Value',TunableParameters(strcmp('C',{TunableParameters.Name})).Value,...
                              'Tunable','on');

FilteredTunableParameters(4) = struct('Name','D',...
                              'Value',TunableParameters(strcmp('D',{TunableParameters.Name})).Value,...
                              'Tunable','on');                       
                          
FilteredTunableParameters(5) = struct('Name','SampleTime',...
                              'Value',TunableParameters(strcmp('SampleTime',{TunableParameters.Name})).Value,...
                              'Tunable','off');

FilteredTunableParameters(6) = struct('Name','method',...
                          'Value',method,...
                          'Tunable','off'); 
                      
FilteredTunableParameters(7) = struct('Name','Wc',...
                          'Value',TunableParameters(strcmp('Wc',{TunableParameters.Name})).Value,...
                          'Tunable','off'); 


S = struct('TunableParameters',FilteredTunableParameters,...
           'EvalFcn',EvalFcn,...
           'InvFcn',InvFcn,...
           'Constraints',Constraints,...
           'Inport',1,...
           'Outport',1);

function [C,Cfixed] = LocalEvalFcn(TunableParameters)

sys = zpk(ss(TunableParameters(1).Value,TunableParameters(2).Value,...
    TunableParameters(3).Value,TunableParameters(4).Value));
ts = TunableParameters(5).Value;
method = TunableParameters(6).Value;
if strcmp(method,'prewarp')
  WcRad = TunableParameters(7).Value*2*pi;
  C = c2d(sys,ts,method,WcRad);
else
  C = c2d(sys,ts,method);
end

% Set gain of 1 as the fixed compensator
Cfixed = zpk([],[],1,ts);

function TunableParameters_out = LocalInvFcn(TunableParameters_in,z,p,k)
% Initialize parameters
TunableParameters_out = TunableParameters_in;

% Convert from discrete ZPK to continuous zpk using D2C with the same method    
sysd = zpk(z,p,k,TunableParameters_in(5).Value);
if strcmp(TunableParameters_in(6).Value,'prewarp')
  WcRad = TunableParameters_in(7).Value*2*pi;
  sys = d2c(sysd,TunableParameters_in(6).Value,WcRad);
else
  sys = d2c(sysd,TunableParameters_in(6).Value);
end
[A,B,C,D] = ssdata(sys);

TunableParameters_out(1).Value = A;
TunableParameters_out(2).Value = B;
TunableParameters_out(3).Value = C;
TunableParameters_out(4).Value = D;



    
       
       
       