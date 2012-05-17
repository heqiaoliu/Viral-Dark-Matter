function Dzpk = zpk(D)
% Conversion to ZPK

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision $  $Date: 2010/02/08 22:47:59 $

% Check result is representable as TF with I/O delays
iod = getIODelay(D);
Ts = D.Ts;
if any(isnan(iod(:)))
   if Ts==0
      ctrlMsgUtils.error('Control:transformation:zpk3')
   else
      ctrlMsgUtils.warning('Control:ltiobject:UseSSforInternalDelay')
      D = elimDelay(D,[],[],D.Delay.Internal);
      iod = zeros(iosize(D));
   end
end

% Compute ZPK data
% RE: Use IODYNAMICS to perform various reductions in right order
[z,p,k] = iodynamics(D);

% Create result
Dzpk = ltipack.zpkdata(z,p,k,Ts);

% Set delays
Delay = D.Delay;
Dzpk.Delay.Input = Delay.Input;
Dzpk.Delay.Output = Delay.Output;
Dzpk.Delay.IO = iod;

