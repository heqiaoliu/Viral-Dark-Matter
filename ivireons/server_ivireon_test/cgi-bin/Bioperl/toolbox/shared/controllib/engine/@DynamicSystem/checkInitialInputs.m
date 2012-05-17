function [sysList,t,x0] = checkInitialInputs(sysList,Extras)
% Validates input arguments to INITIAL.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:34 $
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
      ctrlMsgUtils.error('Control:analysis:rfinputs04')
   case 1
      x0 = Extras{1};  t = [];
   case 2
      x0 = Extras{1};  t = checkTimeSpec(0,Extras{2});
   otherwise
      ctrlMsgUtils.error('Control:analysis:rfinputs01')
end

% Check initial condition
if ~isempty(x0)
   if ~(isnumeric(x0) && isreal(x0) && isvector(x0) && all(isfinite(x0)))
      ctrlMsgUtils.error('Control:analysis:rfinputs17')
   end
   x0 = full(double(x0(:)));
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
   sysList(ct).System = checkComputability(sysList(ct).System,'initial',t,x0);
end

