function S = MDTransferFcnIC(this,blockname,TunableParameters)
% MDTRANSFERFCNIC This is the configuration function for the discretized
% transfer function block with initial states.
%

% Author(s): Erman Korkut 22-Apr-2008
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:34:23 $

% Setup evaluation and inverse function
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
          
FilteredTunableParameters(1) = struct('Name','Numerator',...
                              'Value',TunableParameters(strcmp('Numerator',{TunableParameters.Name})).Value,...
                              'Tunable','on');

FilteredTunableParameters(2) = struct('Name','Denominator',...
                              'Value',TunableParameters(strcmp('Denominator',{TunableParameters.Name})).Value,...
                              'Tunable','on');
                          
FilteredTunableParameters(3) = struct('Name','X0',...
                              'Value',TunableParameters(strcmp('X0',{TunableParameters.Name})).Value,...
                              'Tunable','off');                          
                          
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
if ~isvector(TunableParameters(1).Value) || ~isvector(TunableParameters(2).Value)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidDTFNumDen')
end

% Get parameters
num = TunableParameters(1).Value;
den = TunableParameters(2).Value;
ts = TunableParameters(4).Value;
method = TunableParameters(5).Value;

sys = zpk(tf(num,den));
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
k_orig = k;

% If zpk gain is set to zero, calculate everything as if it is 1
if k_orig == 0
    k = 1;
end

% Convert from discrete ZPK to continuous zpk using D2C with the same method    
sysd = zpk(z,p,k,TunableParameters_in(4).Value);
if strcmp(TunableParameters_in(5).Value,'prewarp')
  WcRad = TunableParameters_in(6).Value*2*pi;
  sys = d2c(sysd,TunableParameters_in(5).Value,WcRad);
else
  sys = d2c(sysd,TunableParameters_in(5).Value);
end
[num,den] = tfdata(sys,'v');

if k_orig == 0
    TunableParameters_out(1).Value = 0;
else
    % Find the hard zeros leading the numerator
    ind = find(num,1);
    TunableParameters_out(1).Value = num(ind:end);
end

TunableParameters_out(2).Value = den;
