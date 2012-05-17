function Dtf = tf(D)
% Conversion to TF

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision $  $Date: 2010/02/08 22:47:55 $

% Check result is representable as TF with I/O delays
iod = getIODelay(D);
if any(isnan(iod(:)))
   if D.Ts==0
      ctrlMsgUtils.error('Control:transformation:tf3')
   else
      ctrlMsgUtils.warning('Control:ltiobject:UseSSforInternalDelay')
      D = elimDelay(D,[],[],D.Delay.Internal);
   end
end

% Go through ZPK representation
Dtf = tf(zpk(D));
