function S = DZPKIO(this,blockname,TunableParameters)
% DZPKIO  This is the configuration function for the discrete
% zero pole block with initial outputs.
%

% Author(s): Erman Korkut 22-Apr-2008
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:34:19 $

% Set up the evaluation function
EvalFcn = @LocalEvalFcn;

% Set up the inverse function
InvFcn = @LocalInvFcn;
    
FilteredTunableParameters(1) = struct('Name','Z',...
                              'Value',TunableParameters(strcmp('Z',{TunableParameters.Name})).Value,...
                              'Tunable','on');

FilteredTunableParameters(2) = struct('Name','P',...
                              'Value',TunableParameters(strcmp('P',{TunableParameters.Name})).Value,...
                              'Tunable','on');

FilteredTunableParameters(3) = struct('Name','K',...
                              'Value',TunableParameters(strcmp('K',{TunableParameters.Name})).Value,...
                              'Tunable','on');
                          
FilteredTunableParameters(4) = struct('Name','TS',...
                              'Value',TunableParameters(strcmp('TS',{TunableParameters.Name})).Value,...
                              'Tunable','off');                          
                          
FilteredTunableParameters(5) = struct('Name','U0',...
                              'Value',TunableParameters(strcmp('U0',{TunableParameters.Name})).Value,...
                              'Tunable','off');
                          
FilteredTunableParameters(6) = struct('Name','Y0',...
                              'Value',TunableParameters(strcmp('U0',{TunableParameters.Name})).Value,...
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
if (~isvector(S(1).Value) && ~isempty(S(1).Value)) ||...
            (~isvector(S(2).Value) && ~isempty(S(2).Value))
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKPoleZero')
elseif ~isscalar(S(3).Value)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKGain')
end

% Computed the tune component
C = zpk(S(1).Value,S(2).Value,S(3).Value,S(4).Value);
% The fixed element is a gain of 1
Cfixed = zpk([],[],1,S(4).Value);

%% ------------------------------------------------------------------------
function S = LocalInvFcn(S,z,p,k)

% Compute the inverse
S(1).Value = z;
S(2).Value = p;
S(3).Value = k;



    
       
       
       