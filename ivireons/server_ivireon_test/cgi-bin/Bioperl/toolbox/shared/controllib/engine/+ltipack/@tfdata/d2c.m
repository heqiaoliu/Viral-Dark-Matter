function Dc = d2c(Dd,options)
%D2C  Conversion of discrete transfer functions to continuous time.

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:30 $

method = options.Method(1);

if any(strncmp(method,{'m','t'},1))
   % Use @zpkdata algorithm
   Dc = tf(d2c(zpk(Dd),options));
else
   % Convert each I/O transfer function using state-space algorithm
   Dc = Dd;
   Dc.Ts = 0;
   [ny,nu] = size(Dd.num);
   
   % Update delays
   Ts = Dd.Ts;
   Dc.Delay.Input = Ts * Dd.Delay.Input;
   Dc.Delay.Output = Ts * Dd.Delay.Output;
   Dc.Delay.IO = Ts * Dd.Delay.IO;
   
   % Create SISO buffer
   Dtf = Dd;
   Dtf.Delay.Input = 0;
   Dtf.Delay.Output = 0;
   Dtf.Delay.IO = 0;
   
   % Loop over I/O pairs
   for ct=1:ny*nu
      Dtf.num = Dd.num(ct);
      Dtf.den = Dd.den(ct);
      if ~isproper(Dtf)
         ctrlMsgUtils.error('Control:transformation:NotSupportedImproperZOH','d2c')
      end
      % Discretize
      Dtfd = tf(d2c(ss(Dtf),options));
      % Update corresponding I/O pair in discrete TF
      Dc.num(ct) = Dtfd.num;
      Dc.den(ct) = Dtfd.den;
   end
end
