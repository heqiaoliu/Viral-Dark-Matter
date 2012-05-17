function [y,x] = lsim(D,u,t,x0,InterpRule) %#ok<INUSL>
% Linear response simulation of transfer function models.
% U is assumed to be Ns-by-Nu

%	 Author: P. Gahinet
%	 Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:49 $
x = [];
if D.Ts==0
   y = lsim(ss(D),u,t,[],InterpRule);
else
   num = D.num;
   den = D.den;
   % Computability
   if ~isproper(D)
      ctrlMsgUtils.error('Control:general:NotSupportedImproperSys','lsim')
   elseif ~isreal(D)
      ctrlMsgUtils.error('Control:general:NotSupportedComplexData','lsim')
   end
   % Limit delays to simulation horizon to avoid "out of memory" errors in TFSIM
   ns = size(u,1);
   iod = min(getIODelay(D,'total'),ns);
   % Simulate
   InitState = linsimstate('tf',num,den,iod);
   y = tfsim(num,den,iod,u,InitState);
end
