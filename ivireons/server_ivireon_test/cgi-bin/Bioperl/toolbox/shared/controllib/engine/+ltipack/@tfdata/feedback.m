function [D,SingularFlag] = feedback(D1,D2,indu,indy,sign)
% Feedback interconnection of SISO transfer function models.

%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:37 $
if nargin<3
   indy = 1:size(D1.num,1);  
   indu = 1:size(D1.num,2);  
   sign = -1;
end

if isscalar(D1.num) && isscalar(D2.num)
   % SISO case
   Ts = D1.Ts;
   SingularFlag = false;
   
   % Delays
   if hasdelay(D1) || hasdelay(D2)
      if Ts==0
          ctrlMsgUtils.error('Control:combination:InternalDelaysConvert2SS')
      else
          ctrlMsgUtils.warning('Control:ltiobject:UseSSforInternalDelay')
         % Watch for static gains with zero sample time (g183631)
         D1 = elimDelay(D1);
         D2 = elimDelay(D2);
      end
   end

   % Numerator and denominator
   den = conv(D1.den{1},D2.den{1}) - sign * conv(D1.num{1},D2.num{1});
   if all(den==0)
       ctrlMsgUtils.error('Control:combination:feedback8')
   end
   num = conv(D1.num{1},D2.den{1});
   % RE: Eliminate leading zeros, feedback(tf(5,[1 2 5]),tf([1 3],1))
   [num,den] = utRemoveLeadZeros({num},{den});
   
   D = ltipack.tfdata(num,den,Ts);
else
   % Perform calculation in state-space for MIMO models
   [Dss,SingularFlag] = feedback(ss(D1),ss(D2),indu,indy,sign);
   try
      D = tf(Dss);
   catch %#ok<CTCH>
      ctrlMsgUtils.error('Control:combination:InternalDelaysConvert2SS')
   end
end
