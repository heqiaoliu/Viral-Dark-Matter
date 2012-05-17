function Dc = d2c(Dd,options)
%D2C  Conversion of discrete transfer functions to continuous time.

%   Author(s): Clay M. Thompson, P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:25 $

[ny,nu] = size(Dd.k);
Dc = Dd;
Dc.Ts = 0;

% Update delays
Ts = Dd.Ts;
Dc.Delay.Input = Ts * Dd.Delay.Input;
Dc.Delay.Output = Ts * Dd.Delay.Output;
Dc.Delay.IO = Ts * Dd.Delay.IO;

method = options.Method(1);

% Conversion algorithms
switch method
   case 'm'
      % Matched pole-zero
      if ny~=1 || nu~=1
          ctrlMsgUtils.error('Control:transformation:MatchedMethodRequiresSISOModel','d2c')
      end
      tol = sqrt(eps);
      
      z = Dd.z{1};
      p = Dd.p{1};
      z0 = z;  p0 = p;
      RealFlag = isreal(Dd.k) && isconjugate(z) && isconjugate(p);
      
      % Detect zeros and poles at z=0 
      if any(abs(z)<tol) || any(abs(p)<tol),
          ctrlMsgUtils.error('Control:transformation:d2c05')
      end
      
      % Delete zeros at -1 (for consistency with c2d)
      z(abs(z+1)<tol) = [];
      
      % Negative real zeros can be transformed only if their multiplicity is even
      [znr,mult,z] = negreal(z);
      if any(rem(mult,2)),
         ctrlMsgUtils.error('Control:transformation:d2c10')
      else
         zc = [];
         for i = 1:length(znr),
            zci = log(znr(i))/Ts;
            zci = zci(ones(mult(i)/2,1),1);
            zc = [zc ; zci ; conj(zci)]; %#ok<AGROW>
         end
      end
      
      % Negative real poles can be transformed only if their multiplicity is even
      [pnr,mult,p] = negreal(p);
      if any(rem(mult,2)),
          ctrlMsgUtils.error('Control:transformation:d2c04')
      else
         pc = [];
         for i = 1:length(pnr),
            pci = log(pnr(i))/Ts;
            pci = pci(ones(mult(i)/2,1),1);
            pc = [pc ; pci ; conj(pci)]; %#ok<AGROW>
         end
      end
      
      % Zero/pole r mapped to log(r)/Ts
      zc = [zc ; log(z)/Ts];
      pc = [pc ; log(p)/Ts];
      
      % Match D.C. gain or gain at z=exp(s0*Ts) for s0=1e-3/Ts or some
      % multiple thereof (NOTE: s0 value should be consistent with
      % value used in C2D to make D2C(C2D(...)) an involutive op.
      sm = 0;
      zm = 1;
      while any(abs([z0;p0]-zm)<sqrt(eps)),
         sm = sm + 1e-3/Ts;
         zm = exp(sm*Ts);
      end
      dcd = Dd.k * prod(zm-z0)/prod(zm-p0);
      kc = dcd * prod(sm-pc)/prod(sm-zc);
      
      % Require that gain be real
      if RealFlag
         kc = real(kc);
      end
      
      Dc.z = {zc};
      Dc.p = {pc};
      Dc.k = kc;
      
      
   case 't'
      % Tustin approximation
      w = options.PrewarpFrequency;
      if w == 0
          c = 2/Ts;
      else
          % Handle prewarping
          c = w/tan(w*Ts/2);
      end
     
      for ct=1:ny*nu
         z = Dd.z{ct};   
         p = Dd.p{ct};   
         k = Dd.k(ct);
         lpmz = length(p) - length(z);
         RealFlag = isreal(k) & isconjugate(z) & isconjugate(p);
         
         % Each factor (z-rj) is transformed to
         %             s - c (rj-1)/(rj+1)
         %    -(1+rj)  -------------------
         %                     s - c
         % Handle zeros first
         zp1 = z + 1;
         zm1 = z - 1;
         ix = (zp1==0);
         % Zeros s.t. z+1~=0 mapped to c(z-1)/(z+1), other contribute to gain
         z = c * zm1(~ix,1)./zp1(~ix,1); 
         k = k * prod(c*zm1(ix,1)) * prod(-zp1(~ix,1));
         
         % Then handle poles:
         pp1 = p + 1;
         pm1 = p - 1;
         ix = (pp1==0);
         % Poles s.t. z+1~=0 mapped to c(p-1)/(p+1), other contribute to gain
         p = c * pm1(~ix,1)./pp1(~ix,1); 
         k = k / prod(c*pm1(ix,1)) / prod(-pp1(~ix,1));
         if RealFlag
            k = real(k);
         end
         
         % (s-c) factors may contribute additional poles or zeros
         Dc.z{ct} = [z ; c * ones(lpmz,1)];
         Dc.p{ct} = [p ; c * ones(-lpmz,1)];
         Dc.k(ct) = k;
      end
      
   otherwise
      % ZOH method
      % Discretize each I/O transfer function using state-space algorithm
      Dzpk = Dd; % SISO buffer
      Dzpk.Delay.Input = 0;
      Dzpk.Delay.Output = 0;
      Dzpk.Delay.IO = 0;
      
      % Loop over I/O pairs
      for ct=1:ny*nu
         Dzpk.z = Dd.z(ct);
         Dzpk.p = Dd.p(ct);
         Dzpk.k = Dd.k(ct);
         if ~isproper(Dzpk)
             ctrlMsgUtils.error('Control:transformation:NotSupportedImproperZOH','d2c')
         end
         Dzpkc = zpk(d2c(ss(Dzpk),options));
         % Update corresponding I/O pair in discrete TF
         Dc.z(ct) = Dzpkc.z;
         Dc.p(ct) = Dzpkc.p;
         Dc.k(ct) = Dzpkc.k;
      end
      
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  [rnr,mult,r] = negreal(r)
%NEGREAL  Finds negative real roots and their multiplicity

mult = [];
rnr = [];

% Get negative real roots
inr = find(imag(r)==0 & real(r)<0);
rnr0 = r(inr);
r(inr) = [];

% Determine multiplicities
while ~isempty(rnr0),
   t = rnr0(1);
   ix = find(abs(t-rnr0)<sqrt(eps)*max(1,-t));
   rnr = [rnr t]; %#ok<AGROW>
   mult = [mult length(ix)]; %#ok<AGROW>
   rnr0(ix) = [];
end




