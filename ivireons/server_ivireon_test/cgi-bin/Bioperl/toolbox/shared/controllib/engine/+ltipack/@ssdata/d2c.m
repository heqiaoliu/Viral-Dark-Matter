function Dc = d2c(Dd,options)
%D2C  Conversion of discrete state-space models to continuous time.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:50 $

method = options.Method(1);

switch method
   case 'm'
      % Use zpkdata algorithm (Note: zpk conversion never fails for
      % discrete models)
      Dc = ss(d2c(zpk(Dd),options));

   case 'z'
      % Zero-order hold approximation
      % Check causality
      [isProper,Dd] = isproper(elimZeroDelay(Dd),'explicit');
      if ~isProper
         ctrlMsgUtils.error('Control:transformation:NotSupportedImproperZOH','d2c')
      end
      % Compute equivalent model
      Dc = utInvDiscretizeZOH(Dd);

   case 't'
      % Tustin approximations
      % Handle prewarp      
      w = options.PrewarpFrequency;
      if w == 0
          r = 2/Dd.Ts;
      else
          % Handle prewarping
          r = w/tan(w*Dd.Ts/2);
      end
      
      nx = size(Dd.a,1);

      if isempty(Dd.e)
         % Explicit SS
         % Prevent scaling-induced "near singularity" (g330910)
         [ms,bs,cs,~,s] = aebalance(eye(nx)+Dd.a,Dd.b,Dd.c,[],'safebal','noperm');
         [l,u,p] = lu(ms,'vector');
         if rcond(u)<eps,
            ctrlMsgUtils.error('Control:transformation:d2c06')
         end
         si = 1./s;
         aux = lrscale(Dd.a,si,s)-eye(nx);
         ac = r * (u\(l\aux(p,:)));
         bc = u\(l\bs(p,:));
         aux = zeros(size(cs));
         aux(:,p) = r*((cs/u)/l);
         dc = Dd.d - cs * bc;
         ac = lrscale(ac,s,si);
         bc = lrscale(2*bc,s,[]);
         cc = lrscale(aux,[],si);
         ec = [];

      else
         % Descriptor SS
         ad = Dd.a;   ed = Dd.e;
         m = ed + ad;
         [ms,bs,cs,~,s] = aebalance(m,Dd.b,Dd.c,[],'safebal','noperm');
         [l,u,p] = lu(ms,'vector');
         if rcond(u)<eps,
            ctrlMsgUtils.error('Control:transformation:d2c06')
         end
         aux = zeros(size(cs));
         aux(:,p) = (cs/u)/l;
         ac = r * (ad - ed);
         bc = 2 * Dd.b;
         cc = r * lrscale(aux,[],1./s) * ed;
         dc = Dd.d - aux*bs;
         ec = m;
      end

      % Update delays and sample time
      % Discard state names because of bilinear transformation
      Dc = ltipack.ssdata(ac,bc,cc,dc,ec,0);
      Ts = Dd.Ts;
      Dc.Delay.Input = Ts * Dd.Delay.Input;
      Dc.Delay.Output = Ts * Dd.Delay.Output;
      Dc.Delay.Internal = Ts * Dd.Delay.Internal;
end


