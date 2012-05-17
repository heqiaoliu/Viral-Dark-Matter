function s = allmargin(D,w)
%ALLMARGIN  Compute all stability margins and crossover frequencies.
%           (algorithm for analytic models)
%
%   Note: Frequency grid w is used for interpolation-based 
%         computation only (see g347538)

%   Author(s): P.Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:09 $
if ~isreal(D)
    ctrlMsgUtils.error('Control:general:NotSupportedComplexData','allmargin')
end
% Tolerances and key parameters
rtol = 1e-3;     % relative accuracy on computed crossings/margins
Ts = abs(D.Ts);  % sampling time

% Determine if delays reducible to pure I/O delays
Td = getIODelay(D,'total');
if hasInfNaN(Td)
   % Code path for internal delays
   % Compute frequency response (use Grade=3 for accurate phase profile)
   if nargin<2
      w = [];
   end
   [mag,phase,w] = freqresp(D,3,w,true);
   Td(isnan(Td)) = 0;
   s = allmargin(mag,(180/pi)*phase,w,Ts,Td);
   
else
   % Code path for models with only I/O delays
   % Compute ZPK representation
   Dzpk = zpk(pade(D,0,0,0));
   Dzpk.Delay.IO = Td;
   z = Dzpk.z{1};
   p = Dzpk.p{1};
   k = Dzpk.k;
   
   % Construct output 
   s = struct(...
      'GainMargin',[],...
      'GMFrequency',[],...
      'PhaseMargin',[],...
      'PMFrequency',[],...
      'DelayMargin',[],...
      'DMFrequency',[],...
      'Stable',[]);

   % Quick exit if k=0
   if k==0
      s.GainMargin = zeros(1,0);    s.GMFrequency = zeros(1,0);
      s.PhaseMargin = zeros(1,0);   s.PMFrequency = zeros(1,0);
      s.DelayMargin = zeros(1,0);   s.DMFrequency = zeros(1,0);
      s.Stable = true;
      return
   end

   % Adjustments for DT   
   if Ts,
      Td = Td*Ts;
      % g198224: watch for roundoff errors near z=1
      p(abs(p-1)<1e3*eps) = 1;
      z(abs(z-1)<1e3*eps) = 1;
   end

   % Carry out pole/zero cancellations (for better convergence)
   %   * 0dB crossings: cancel allpass pole/zero pairs
   %   * -180 crossings: cancel matching pole/zero pairs
   [z0,p0,z180,p180] = cancelzp(z,p,Ts,rtol);
   
   % Phase margins
   if isempty(z0) && isempty(p0)
      % Allpass system
      [wc0,Pm] = LocalAllPass(D,k,Ts,Td,rtol);
   else
      % Compute all 0dB crossings WC0
      if Ts,
         wc0 = dgaincross(z0,p0,k,Ts,rtol);
      else
         wc0 = gaincross(z0,p0,k,rtol);
      end

      if isempty(wc0)
         % No 0dB crossings
         wc0 = zeros(1,0);
         Pm = zeros(1,0);
      else
         % Compute phase at crossing frequencies WC
         ph = angle(fresp(Dzpk,wc0));
         ph = reshape(ph,size(wc0));
         ph(ph<0 & ph>-1e3*eps) = 0;  % prevent getting Pm=180 when ph=-eps
         Pm = mod(ph,2*pi) - pi;      % phase margins in radians
      end
   end
   s.PMFrequency = wc0;
   s.PhaseMargin = (180/pi)*Pm;  % phase margins in degrees

   % Compute Delay margins
   Dm = utComputeDelayMargins(Pm,wc0,Ts,Td,rtol);
   s.DMFrequency = wc0;
   s.DelayMargin = Dm;

   % Gain margins
   if Ts
      wc180 = dphasecross(z180,p180,k,Ts,Td,rtol,wc0);
   else
      wc180 = phasecross(z180,p180,k,Td,rtol,wc0);
   end

   if isempty(wc180)
      % No 180 degree crossings
      s.GMFrequency = zeros(1,0);
      s.GainMargin = zeros(1,0);
   else
      % Compute gain at crossing frequencies WC
      g = abs(fresp(Dzpk,wc180));
      g = reshape(g,size(wc180));
      iszero = (g==0);
      g(iszero) = Inf;
      g(~iszero) = 1./g(~iszero);

      s.GMFrequency = wc180;
      s.GainMargin = g;
   end

   % Stability assessment
   if Td>0
      % Use Nyquist criterion for systems with delay
      s.Stable = LocalNyquistStability(z,p,k,Ts,Td,s);
   elseif isempty(z) && isempty(p)
      % No dynamics: watch for algebraic loops with pure gains
      s.Stable = (k~=-1);
   else
      % No delay: compute closed-loop poles (zeros of 1+h(s))
      Dss = ss(D);
      Dss.d = 1+Dss.d;
      clp = zero(Dss);
      if Ts
         % Discrete time
         s.Stable = all(abs(clp)<1);
      else
         % Continuous time
         s.Stable = all(real(clp)<0);
      end
   end

   % Delay margin: add contribution from other portions of the analytic boundary
   if s.Stable
      reldeg = length(z)-length(p);
      if (reldeg>0 || (reldeg==0 && abs(k)>=1)) && ~any(isinf(s.DMFrequency))
         % 1) Contribution from infinity: zero delay margin at Inf if |H(inf)|>=1
         s.DMFrequency = [s.DMFrequency,Inf];
         s.DelayMargin = [s.DelayMargin,0];
      elseif Ts && (abs(evalfr(D,-1))>=1 || ~LocalNyquistStability(z,p,k,Ts,Td+Ts,s))
         % 2) Contribution of (-Inf,-1] in discrete time: add delay margin of one sample
         %    period if H(z)/z is closed-loop unstable (sufficient condition is |H(-1)|>=1)
         % RE: looking at positive delays only...
         s.DMFrequency = [s.DMFrequency,pi/Ts];
         s.DelayMargin = [s.DelayMargin,1];
      end
   end
end

%--------------------- Local Functions --------------------

%%%%%%%%%%%%%%%%
% LocalAllPass %
%%%%%%%%%%%%%%%%
function [wc0,Pm] = LocalAllPass(D,k,Ts,Td,rtol)
% Computes phase margins for allpass system

if abs(1-abs(k))>rtol,
   % Gain is not 0dB
   wc0 = zeros(1,0);
   Pm = zeros(1,0);

elseif Ts>0 && k<0
   % DT with pure negative gain
   wc0 = 0;
   Pm = 0;

elseif Ts==0 && (k<0 || Td)
   % Continuous time: phase is -180 at Inf or crosses -180 for w large enough when Td>0
   wc0 = Inf;
   Pm = 0;

else
   % Absorb delay into system and use that phase margin is min.
   % where S=1/(1+D) peaks
   Dss = ss(D);
   if Ts~=0
      Dss = elimDelay(Dss);
   end
   % Construct realization of S=1/(1+D) (note: allpass is always proper)
   d = Dss.d;
   c = -Dss.c/(1+d);
   Dss.a = Dss.a + Dss.b * c;   Dss.b = Dss.b/(1+d);  Dss.c = c;   Dss.d = 1/(1+d);
   hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
   [~,wc0] = norminf(Dss,1e-2);
   % RE: Use original model to evaluate freq response
   if Ts==0
      Pm = mod(angle(evalfr(D,1i*wc0)),2*pi)-pi;
   else
      Pm = mod(angle(evalfr(D,exp(1i*wc0*Ts))),2*pi)-pi;
   end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalNyquistStability %
%%%%%%%%%%%%%%%%%%%%%%%%%%
function isStable = LocalNyquistStability(z,p,k,Ts,Td,s)
% Assesses stability of continuous-time model w/ delay using Nyquist criterion

% System is unstable if phase margin is zero
if any(abs(s.PhaseMargin(isfinite(s.PhaseMargin)))<180*sqrt(eps))
   isStable = false;
   return
end

% Compute (counterclockwise) winding number of H(jw) around (-1,0)
Wcg = s.PMFrequency;
Wcg = Wcg(:,isfinite(Wcg));
Wcg = unique([-Wcg,Wcg]);    % 0dB crossovers
if Ts==0
   N = winding(z,p,k,Td,Wcg);
   P = sum(real(p)>0);   % number of unstable open-loop poles
else
   N = dwinding(z,p,k,Ts,Td/Ts,Wcg);
   P = sum(abs(p)>1);    % number of unstable open-loop poles
end
isStable = (N==P);    % Nyquist criterion

