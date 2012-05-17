function S = DFilterFcn(this,blockname)
% DFILTERFCN  This is the configuration function for the discrete 
% filter function block
%

% Author(s): John W. Glass 18-Jul-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2007/10/15 23:31:07 $
                          
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
%% In this function the filter is in the form
%
%            1+a1 z^-1+a2 z^-2
%  F =  ---------------------------
%        1+b1 z^-1+b2 z^-2+b3 z^-3
%
% needs to be converted to
%
%          z^3+a1 z^2+a2 z^1
%  TF =  ---------------------
%         z^3+b1 z^2+b2 z^1+b3
%

% Error checking
if ~isvector(S(1).Value) || ~isvector(S(2).Value)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidDFilterNumDen')
end

% Make sure that num and den are row vectors
num = S(1).Value;
if size(num,2) == 1
    num = num';
end
den = S(2).Value;
if size(den,2) == 1
    den = den';
end

% Find the relative order of the filter
relorder = length(den) - length(num);
       
% Computed the tune component
C = zpk(tf(num,den,S(3).Value));

% Pad the numerator to account for zeros or poles at zero
if relorder > 0
    C.z{1} = [C.z{1};zeros(relorder,1)];
else
    C.p{1} = [C.p{1};zeros(-relorder,1)];
end

% The fixed element is a gain of 1
Cfixed = zpk([],[],1,S(3).Value);

%% ------------------------------------------------------------------------
function S = LocalInvFcn(S,z,p,k)

% Computed the inverse
[num,den]=tfdata(zpk(z,p,k,S(3).Value),'v');

% Find the hard zeros trailing the numerator and denominator
ind = find(num,1,'last');
num = num(1:ind);
ind = find(den,1,'last');
den = den(1:ind);

S(1).Value = num;
S(2).Value = den;