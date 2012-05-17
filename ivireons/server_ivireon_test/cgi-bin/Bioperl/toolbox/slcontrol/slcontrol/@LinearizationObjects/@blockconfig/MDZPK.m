function S = MDZPK(this,blockname,TunableParameters)
% MDZPK  This is the configuration function for the discretized
% zero pole block.
%

% Author(s): Erman Korkut 22-Apr-2008
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:34:24 $

EvalFcn = @LocalEvalFcn;
InvFcn = @LocalInvFcn;

method = TunableParameters(strcmp('method',{TunableParameters.Name})).Value;
% Reject to do control design if the method is foh (D2C does not support it)
if strcmp(method,'foh')
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidDiscretizationMethod');
end
% If the method is 'zoh' or 'imp', do not allow improper controllers(C2D requirement)
if strcmp(method,'zoh') || strcmp(method,'imp')
    Constraints = struct('MaxZeros',inf,'MaxPoles',inf,'isStaticGainTunable',true,'allowImproper',false);
else
    Constraints = struct('MaxZeros',inf,'MaxPoles',inf,'isStaticGainTunable',true);
end
            
FilteredTunableParameters(1) = struct('Name','Zeros',...
                              'Value',TunableParameters(strcmp('Zeros',{TunableParameters.Name})).Value,...
                              'Tunable','on');

FilteredTunableParameters(2) = struct('Name','Poles',...
                              'Value',TunableParameters(strcmp('Poles',{TunableParameters.Name})).Value,...
                              'Tunable','on');

FilteredTunableParameters(3) = struct('Name','Gain',...
                              'Value',TunableParameters(strcmp('Gain',{TunableParameters.Name})).Value,...
                              'Tunable','on');
                          
FilteredTunableParameters(4) = struct('Name','SampleTime',...
                              'Value',TunableParameters(strcmp('SampleTime',{TunableParameters.Name})).Value,...
                              'Tunable','off');

FilteredTunableParameters(5) = struct('Name','method',...
                          'Value',method,...
                          'Tunable','off'); 
                      
FilteredTunableParameters(6) = struct('Name','Wc',...
                          'Value',TunableParameters(strcmp('Wc',{TunableParameters.Name})).Value,...
                          'Tunable','off'); 


S = struct('TunableParameters',FilteredTunableParameters,...
           'EvalFcn',EvalFcn,...
           'InvFcn',InvFcn,...
           'Constraints',Constraints,...
           'Inport',1,...
           'Outport',1);

function [C,Cfixed] = LocalEvalFcn(TunableParameters)
% Check input sizes
if (~isvector(TunableParameters(1).Value) && ~isempty(TunableParameters(1).Value)) ||...
            (~isvector(TunableParameters(2).Value) && ~isempty(TunableParameters(2).Value))
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKPoleZero')
elseif ~isscalar(TunableParameters(3).Value)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKGain')
end
% Get parameters
z = TunableParameters(1).Value;
p = TunableParameters(2).Value;
k = TunableParameters(3).Value;
ts = TunableParameters(4).Value;
method = TunableParameters(5).Value;

sys = zpk(z,p,k);
if strcmp(method,'prewarp')
  WcRad = TunableParameters(6).Value*2*pi;
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
sysd = zpk(z,p,k,TunableParameters_in(4).Value);
if strcmp(TunableParameters_in(5).Value,'prewarp')
  WcRad = TunableParameters_in(6).Value*2*pi;
  sys = d2c(sysd,TunableParameters_in(5).Value,WcRad);
else
  sys = d2c(sysd,TunableParameters_in(5).Value);
end

[zinv,pinv,kinv] = zpkdata(sys,'v');

TunableParameters_out(1).Value = zinv;
TunableParameters_out(2).Value = pinv;
TunableParameters_out(3).Value = kinv;

    
       
       
       