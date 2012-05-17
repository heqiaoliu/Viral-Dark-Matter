function n = normh2(D)
% H2 norm of state-space model

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:30 $
Ts = D.Ts;

% Determine if internal delays are equivalent to input+output delays,
% in which case they can be ignored
if norm_hasInternalDelay(D)
   if Ts==0
      throw(ltipack.utNoDelaySupport('norm',0,'internal'))
   else
      D = elimDelay(D,[],[],D.Delay.Internal);
   end
end

% Check properness
[isProper,D] = isproper(D);
if ~isProper
   if Ts==0
      ctrlMsgUtils.warning('Control:analysis:NormInfinite2')
      n = Inf;
      return
   else
      ctrlMsgUtils.error('Control:analysis:norm3');
   end
end

% Extract data (use getABCD to properly handle I/O delays)
if isreal(D.a) && isreal(D.b) && isreal(D.e)
   [a,b,c,d,~,e] = getABCDE(D);
else
   % Get explicit form (no complex descriptor version of Lyapunov solvers)
   [a,b,c,d] = getABCD(D);  e = [];
end

% Compute norm
if Ts==0,
   % Continuous H2 norm: 
   if norm(d,1)>0
      ctrlMsgUtils.warning('Control:analysis:NormInfinite1')
      n = Inf;
   else
      try
         % || G || = || R*c' ||_F where R'*R=P and a*P+P*a'+b*b' = 0
         R = lyapchol(a,b,e);
         n = norm(R*c','fro');    % = sqrt(trace(c*P*c'))
      catch %#ok<*CTCH>
         ctrlMsgUtils.warning('Control:analysis:NormInfinite3')
         n = Inf;
      end
   end
else
   % Discrete H2 norm:
   try
      % || G ||^2 = trace(c*P*c'+d*d') where a*P*a'-P+b*b' = 0
      R = dlyapchol(a,b,e);
      n = norm([R*c';d'],'fro');  % = sqrt(trace(c*P*c'+d*d'))
   catch
      ctrlMsgUtils.warning('Control:analysis:NormInfinite3')
      n = Inf;
   end
end
