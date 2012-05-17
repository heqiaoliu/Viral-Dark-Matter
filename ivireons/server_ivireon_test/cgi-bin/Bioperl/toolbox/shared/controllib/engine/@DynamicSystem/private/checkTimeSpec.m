function t = checkTimeSpec(t0,t)
% Checks time input is valid vector or final time.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:51:31 $

% RE: T0 = start time of event-based simulation (e.g., t0=0 for step)
if isempty(t)
   return
elseif isscalar(t)
   % Final time
   if ~(isnumeric(t) && isreal(t))
      ctrlMsgUtils.error('Control:analysis:rfinputs13')
   end
   t = full(double(t));
   if t<=0,
      ctrlMsgUtils.error('Control:analysis:rfinputs13')
   elseif ~isfinite(t)
      t = [];
   end
elseif isvector(t)
   % Time vector specified
   if ~(isnumeric(t) && isreal(t))
      ctrlMsgUtils.error('Control:analysis:rfinputs14')
   end
   t = full(double(t(:)));  t0 = double(t0);
   dt = t(2)-t(1);
   if any(diff(t)<=0) || ~all(isfinite(t)) || any(abs(diff(t)-dt)>0.01*dt)
      ctrlMsgUtils.error('Control:analysis:rfinputs14')
   elseif t(1)<t0
      % Simulation with event at t=t0 (step,...)
      ctrlMsgUtils.error('Control:analysis:rfinputs15',t0)
   end
   % Enforce even spacing
   nt0 = round((t(1)-t0)/dt);
   t = t0 + dt * (nt0:nt0-1+length(t))';
else
   ctrlMsgUtils.error('Control:analysis:rfinputs16')
end

