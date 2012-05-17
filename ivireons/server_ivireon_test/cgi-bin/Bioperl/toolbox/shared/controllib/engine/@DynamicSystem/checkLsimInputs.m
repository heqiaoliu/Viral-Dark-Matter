function [sysList,t,x0,u,InterpRule] = checkLsimInputs(sysList,Extras)
% Validates input arguments to LSIM.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:35 $

% Interpolation rule
ioh = find(strcmpi('zoh',Extras) | strcmpi('foh',Extras));
if ~isempty(ioh)
   InterpRule = Extras{ioh};
   Extras(ioh) = [];
else
   InterpRule = 'auto';
end

% Get sampling times
nsys = length(sysList);
Ts = zeros(nsys,1);
for ct=1:nsys
   Ts(ct) = sysList(ct).System.Ts;
end

if isempty(Extras)
   % Bypass for LSIM(SYS) (launches LSIM GUI to specify t,u)
   t = [];  u = [];  x0 = [];
   
   % Check if response is computable for specified systems
   for ct=1:nsys
      sysList(ct).System = checkComputability(sysList(ct).System,'lsim');
   end
else
   % Check optional inputs EXTRAS
   Extras = [Extras cell(1,3-length(Extras))];
   u = Extras{1};  t = Extras{2};  x0 = Extras{3};
   
   % Check input data
   if isempty(u),
      % Convenience for systems w/o input
      ns = max([size(u),length(t)]);
      if ns==0
         ctrlMsgUtils.error('Control:analysis:rfinputs20')
      else
         u = zeros(ns,0);
      end
   else
      su = size(u);
      [~,nu] = iosize(sysList(1).System);
      if length(su)>2 || ~((isnumeric(u) || islogical(u)) && isreal(u) && all(isfinite(u(:))))
         ctrlMsgUtils.error('Control:analysis:rfinputs18')
      elseif ~any(su==nu)
         ctrlMsgUtils.error('Control:analysis:rfinputs19')
      elseif su(2)~=nu
         % Transpose U (users often supply a row vector for SISO systems)
         u = u.';
      end
      u = full(double(u));
      ns = size(u,1);
   end
   if ns<2
      % Need at least two samples
      ctrlMsgUtils.error('Control:analysis:rfinputs18')
   end
   
   % Check time vector
   if isempty(t)
      % No time vector specified. If all systems are discrete with same Ts, use equisampled t
      Tsref = abs(Ts(1));
      if any(Ts==0)
         ctrlMsgUtils.error('Control:analysis:rfinputs05')
      elseif all(Ts==-1) || all(Ts==Tsref),
         % All sample times are equal
         t = Tsref * (0:1:ns-1)';
      else
         ctrlMsgUtils.error('Control:analysis:rfinputs06')
      end
   else
      t0 = t(1:min(1,end));
      t = checkTimeSpec(t0,t);
      if length(t)~=ns
         ctrlMsgUtils.error('Control:analysis:rfinputs19')
      elseif length(t)>1 && abs(t(1))>1e-5*(t(2)-t(1))
         ctrlMsgUtils.warning('Control:analysis:LsimStartTime')
      end
   end
   
   % Check initial condition
   if ~isempty(x0)
      if ~(isnumeric(x0) && isreal(x0) && isvector(x0) && all(isfinite(x0)))
         ctrlMsgUtils.error('Control:analysis:rfinputs17')
      end
      x0 = full(double(x0(:)));
   end
   
   % Check if response is computable for specified systems
   for ct=1:nsys
      sysList(ct).System = checkComputability(sysList(ct).System,'lsim',t,x0,u);
   end

end


