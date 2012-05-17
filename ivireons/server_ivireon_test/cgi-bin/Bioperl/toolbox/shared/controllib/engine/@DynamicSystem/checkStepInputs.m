function [sysList,t] = checkStepInputs(sysList,Extras)
% Validates input arguments to STEP/IMPULSE.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:39 $
nsys = length(sysList);

% Get sampling times
Ts = zeros(nsys,1);
for ct=1:nsys
   Ts(ct) = sysList(ct).System.Ts;
end

% Check optional inputs EXTRAS
nopt = length(Extras);
switch nopt
   case 0
      t = [];
   case 1
      t = checkTimeSpec(0,Extras{1});
   otherwise
      ctrlMsgUtils.error('Control:analysis:rfinputs01')
end

% Check consistency of T with sampling times of plotted systems
lt = length(t);
if lt==0 && any(Ts<0) && any(Ts>0),
   % No specified final time with mix of specified/unspecified 
   % discrete sampling times
   ctrlMsgUtils.error('Control:analysis:rfinputs08')
elseif lt==1 && all(Ts<0) && ~isequal(t,round(t))
   % Unspecified sampling times with non integer final time
   ctrlMsgUtils.error('Control:analysis:rfinputs09')
end  

% Check if response is computable for specified systems
for ct=1:nsys
   sysList(ct).System = checkComputability(sysList(ct).System,'step',t);
end

