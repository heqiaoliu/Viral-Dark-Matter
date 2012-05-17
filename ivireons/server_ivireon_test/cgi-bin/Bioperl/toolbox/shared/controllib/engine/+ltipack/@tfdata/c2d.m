function [Dd,gic] = c2d(Dc,Ts,options)
%C2D  Continuous-to-discrete conversion of transfer functions.

%   Author(s): P. Gahinet
%   Revised: Murad Abu-Khalaf
%   Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:26 $
gic = [];

method = options.Method(1);

if any(strcmp(method,{'m','t'}))
   % Use @zpkdata algorithm
   Dd = tf(c2d(zpk(Dc),Ts,options));
else
   % Discretize each I/O transfer function using state-space algorithm
   Dd = Dc;
   [ny,nu] = size(Dc.num);

   % Extract discrete delays (all fractional delays are absorbed into I/O delay matrix)
   [Delay,fiod] = discretizeDelay(Dc,Ts);
   
   % Create SISO buffer
   Dtf = ltipack.tfdata({[]},{[]},0);
   
   % To minimize the order of the discretized model, push all residual
   % delays to the input for the IMP and FOH methods, and to the 
   % output for the ZOH method (cf. g166286)
   if strcmp(method,'z')
      ioField = 'Output';
   else
      ioField = 'Input';
   end
   
   % Loop over I/O pairs
   for ct=1:ny*nu
      Dtf.num = Dc.num(ct);
      Dtf.den = Dc.den(ct);
      if ~isproper(Dtf)
         ctrlMsgUtils.error('Control:transformation:c2d01','c2d')
      end
      % Discretize
      Dss = ss(Dtf);
      Dss.Delay.(ioField) = fiod(ct)*Ts;  % to avoid increasing order
      Dtfd = tf(c2d(Dss,Ts,options));
      % Update corresponding I/O pair in discrete TF
      Dd.num(ct) = Dtfd.num;
      Dd.den(ct) = Dtfd.den;
      Delay.IO(ct) = Delay.IO(ct) + Dtfd.Delay.Input + Dtfd.Delay.Output;
   end
   
   Dd.Ts = Ts;
   Dd.Delay = Delay;
end
