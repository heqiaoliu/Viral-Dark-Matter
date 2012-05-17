 function S = CTransferFcnIO(this,blockname,TunableParameters) 
% CTRANSFERFCNIO  This is the configuration function for the continuous 
% transfer function block with initial output.
%

% Author(s): Erman Korkut 29-Apr-2008
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2009/06/11 16:08:52 $
                          

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
                          
FilteredTunableParameters(3) = struct('Name','U0',...
                              'Value',TunableParameters(strcmp('U0',{TunableParameters.Name})).Value,...
                              'Tunable','off');

FilteredTunableParameters(4) = struct('Name','Y0',...
                              'Value',TunableParameters(strcmp('Y0',{TunableParameters.Name})).Value,...
                              'Tunable','off');                          


% Create the constraints
Constraints = struct('MaxZeros',inf,'MaxPoles',inf,'isStaticGainTunable',true);

S = struct('TunableParameters',FilteredTunableParameters,...
           'EvalFcn',EvalFcn,...
           'InvFcn',InvFcn,...
           'Constraints',Constraints,...
           'Inport',1,...
           'Outport',1);
       
%% ------------------------------------------------------------------------
function [C,Cfixed] = LocalEvalFcn(S)

% Check input sizes
if ~isvector(S(1).Value) || ~isvector(S(2).Value)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidCTFNumDen')
end

% Computed the tune component
C = zpk(tf(S(1).Value,S(2).Value));
% The fixed element is a gain of 1
Cfixed = zpk([],[],1);

%% ------------------------------------------------------------------------
function S = LocalInvFcn(S,z,p,k)

% Computed the inverse
if k == 0
    S(1).Value = 0;
    den = poly(p);
else
    [num,den]=tfdata(zpk(z,p,k),'v');
    % Find the hard zeros leading the numerator
    ind = find(num,1);
    S(1).Value = num(ind:end);
end

S(2).Value = den;       

