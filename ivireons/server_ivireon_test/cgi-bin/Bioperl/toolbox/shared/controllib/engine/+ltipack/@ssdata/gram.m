function R = gram(D,type)
% Computes Cholesky factor of
%    * Controllability Gramian if TYPE = 'c' or 'cf'
%    * Observability Gramian if TYPE = 'o' or 'of'

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:09 $
Ts = D.Ts;
if hasInternalDelay(D)
   throw(ltipack.utNoDelaySupport('gram',Ts,'internal'))
end
if Ts==0
   LyapSolver = @lyapchol;
else
   LyapSolver = @dlyapchol;
end

% Check that E is nonsingular
[isProper,Dr] = isproper(D);
if ~isProper || order(Dr)<order(D)
    ctrlMsgUtils.error('Control:general:NotSupportedSingularE','gram')
end

% Descriptor only supported for real data
if isreal(D)
   % Use available form
   [a,b,c,d,junk,e] = getABCDE(D);
else
   % Derive explicit form
   [a,b,c] = getABCD(D);   e = [];
end
   
% Solve Lyapunov equation
try
   if any(type=='c')
      R = LyapSolver(a,b,e);
   else
      R = LyapSolver(a',c',e');
      if ~isempty(e)
         % Wo = (R*E)'*(R*E)
         R = R*e;
         if any(type=='f')
            [junk,R] = qr(R);
         end
      end
   end
catch %#ok<CTCH>
     %Some eigenvalue of A or A' lies in the unstable region.
    ctrlMsgUtils.error('Control:foundation:gram3')
end
