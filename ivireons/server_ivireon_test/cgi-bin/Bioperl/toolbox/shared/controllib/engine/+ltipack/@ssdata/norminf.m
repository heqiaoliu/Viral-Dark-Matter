function [gpeak,fpeak] = norminf(D,tol)
% Compute the peak gain GPEAK of the frequency response
%                                   -1
%             G (s) = D + C (sE - A)  B .
%
%   The norm is finite if and only if (A,E) has no eigenvalue on the 
%   imaginary axis.  TOL is the desired relative accuracy on GPEAK, 
%   and FPEAK is the frequency such that:
%
%           || G ( j * PEAKF ) ||  =  GPEAK     (continuous)
%
%                   j*FPEAK*Ts
%           || G ( e           ) ||  =  GPEAK   (discrete)

%    Based on the algorithm described in
%        Bruisma, N.A., and M. Steinbuch, ``A Fast Algorithm to Compute
%        the Hinfinity-Norm of a Transfer Function Matrix,'' Syst. Contr. 
%        Letters, 14 (1990), pp. 287-293.

%       Author(s):  P. Gahinet, 5-13-95.
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:31 $
Ts = abs(D.Ts);

% Determine if internal delays are equivalent to input+output delays,
% in which case they can be ignored
hasInternalDelay = norm_hasInternalDelay(D);
if hasInternalDelay
   if Ts==0
      throw(ltipack.utNoDelaySupport('norm',0,'internal'))
   else
      D = elimDelay(D,[],[],D.Delay.Internal);
   end
end
hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>

% Simplify realization
D = sminreal(D);
if Ts==0
   % Check if proper
   [isProper,D] = isproper(D);
   if ~isProper
      gpeak = Inf;  fpeak = Inf;  return
   end
end
   
% Compute norm   
[a,b,c,d,~,e] = getABCDE(D);
if ~D.Scaled
   % Rescale for freq. response accuracy
   [a,b,c,e] = xscale(a,b,c,d,e,Ts);
end
if Ts==0
   [gpeak,fpeak] = LocalNormInf(a,b,c,d,e,tol);
else
   [gpeak,fpeak] = LocalDNormInf(a,b,c,d,e,Ts,tol);
end

   
%-------------------- Local Function ------------------------------------

function [gpeak,fpeak] = LocalNormInf(a,b,c,d,e,tol)
% Continuous-time norm comp.
% Tolerance for jw-axis mode detection
toljw1 = 100 * eps;       % for simple roots
toljw2 = 10 * sqrt(eps);  % for double root

% Problem dimensions
nx = size(a,1);
desc = ~isempty(e);

% Quick exit in limit cases
if nx==0 || norm(b,1)==0 || norm(c,1)==0,
   gpeak = norm(d);  fpeak = 0;  return
end

% Compute dynamics
if desc
   r = eig(a,e);
else
   r = eig(a);
   e = eye(nx);
end
ar2 = abs(real(r));  % mag. of real part
w0 = abs(r);         % fundamental frequency

% Reduce (A,E) to (generalized) upper-Hessenberg form for
% fast frequency response computation and compute the poles
if desc,
   % Descriptor case
   [aa,ee,q,z] = hess(a,e);
   bb = q*b;
   cc = c*z;
else
   [u,aa] = hess(a);
   bb = u'*b;
   cc = c*u;
   ee = e;
end

% Build a vector TESTFRQ of test frequencies containing the peaking
% frequency for each mode (or an appx thereof for non-resonant modes).
% Add frequency w=0 and set GMIN = || D || and FPEAK to infinity
ikeep = find(imag(r)>=0 & w0>0);
offset2 = max(0.25,1-2*(ar2(ikeep)./w0(ikeep)).^2);
testfrq = [0; w0(ikeep).*sqrt(offset2)];  % test frequencies
gmin = norm(d);
fpeak = Inf;

% Compute lower estimate GMIN as max. gain over selected frequencies
for ct=1:length(testfrq)
   w = testfrq(ct);
   gw = LocalSafeNorm(d+cc*(((1i*w)*ee-aa)\bb));
   if ~isfinite(gw)
      % Singularity
      gpeak = Inf;  fpeak = w;  return
   elseif gw > gmin,
      gmin = gw;  fpeak = w;
   end
end
if gmin==0,
   gpeak = 0; fpeak = 0;  return
end

% Modified gamma iterations (Bruisma-Steinbuch algorithm) start:
iter = 1;
while iter<30,
   % Test if G = (1+TOL)*GMIN qualifies as upper bound
   g = (1+tol) * gmin;
   % Compute finite eigenvalues of Hamiltonian pencil
   heigs = hpeig(a,b,c/g,d/g,e);
   mag = abs(heigs);
   % Detect jw-axis modes.  Test is based on a round-off level of
   % eps*rho(H) (after balancing) resulting in worst-case
   % perturbations of order sqrt(eps*rho(H)) on the real part
   % of poles of multiplicity two (typical as g->norm(sys,inf))
   jweig = heigs(abs(real(heigs)) < toljw2*(1+mag)+toljw1*max(mag));

   % Compute frequencies where gain G is attained and
   % generate new test frequencies
   ws = imag(jweig);
   ws = unique(max(eps,ws(ws>0)));
   lws0 = length(ws);
   if lws0==0
      % No jw-axis eigenvalues for G = GMIN*(1+TOL): we're done
      gpeak = gmin;  return
   else
      if lws0==1
         % Peak width below machine precision or high multiplicity of
         % Hamiltonian eig near s=0 compromised pairing and led to 
         % isolated WS (see tltinorm for example). Treat as degenerate
         % interval and abort after loop below
         ws = [ws,ws]; %#ok<AGROW>
      end
      lws = length(ws);
   end
         
   % Form the vector of mid-points and compute
   % gain at new test frequencies
   gmin0 = gmin;   % save current lower bound
   ws = sqrt(ws(1:lws-1).*ws(2:lws));
   for ct=1:lws-1
      w = ws(ct);
      gw = LocalSafeNorm(d+cc/((1i*w)*ee-aa)*bb);
      if ~isfinite(gw)
         % Singularity
         gpeak = Inf;  fpeak = w;  return
      elseif gw > gmin,
         gmin = gw;  fpeak = w;
      end
   end

   % If lower bound has not improved, exit (safeguard against undetected
   % jw-axis modes of Hamiltonian matrix)
   if lws0<2 || gmin<gmin0*(1+tol/10),
      gpeak = gmin; return
   end
   iter = iter+1;
end %while

%------------------------------------------------------------------------

function [gpeak,fpeak] = LocalDNormInf(a,b,c,d,e,Ts,tol)
% Discrete-time Linf norm
% Tolerance for detection of unit circle modes
toluc1 = 100 * eps;       % for simple roots
toluc2 = 10 * sqrt(eps);  % for double root

% Problem dimensions
nx = size(a,1);
desc = ~isempty(e);

% Quick exits
if nx==0 || norm(b,1)==0 || norm(c,1)==0,
   gpeak = norm(d); fpeak = 0;  return
end

% Compute dynamics
if desc
   r = eig(a,e);
else
   r = eig(a);
   e = eye(nx);
end

% Reduce (A,E) to (generalized) upper-Hessenberg form for
% fast frequency response computation and compute the poles
if desc,
   % Descriptor case
   [aa,ee,q,z] = hess(a,e);
   bb = q*b;
   cc = c*z;
else
   [u,aa] = hess(a);
   bb = u'*b;
   cc = c*u;
   ee = e;
end

% Build a vector TESTFRQ of test frequencies containing the peaking
% frequency for each mode (or an appx thereof for non-resonant modes).
sr = log(r(r~=0 & abs(r)<=pi/Ts));           % equivalent jw-axis modes:
asr2 = abs(real(sr));                        % magnitude of real part
w0 = abs(sr);                                % fundamental frequency
ikeep = find(imag(sr)>=0 & w0>0);
testfrq = w0(ikeep).*sqrt(max(0.25,1-2*(asr2(ikeep)./w0(ikeep)).^2));

% Back to unit circle, and add z = exp(0) and z = exp(pi)
testz = [exp(1i*testfrq) ; -1 ; 1];

% Compute lower estimate GMIN as max. gain over test frequencies
% RE: the norm is always greater then norm(d) (cf. LMI characterization
%     requires B'*X*B+D'*D-g^2*I < 0).  However the value norm(d) may
%     not be achieved at any frequency, so we don't include it.
gmin = 0;
for ct=1:length(testz)
   z = testz(ct);
   gw = LocalSafeNorm(d+(cc/(z*ee-aa))*bb);
   if ~isfinite(gw)
      % Singularity
      gpeak = Inf;  fpeak = abs(angle(z))/Ts;  return
   elseif gw > gmin,
      gmin = gw;  fpeak = abs(angle(z));
   end
end
if gmin==0,
   gpeak = 0;  fpeak = 0;  return
end

% Modified gamma iterations (Bruisma-Steinbuch algorithm) starts:
iter = 1;
while iter<30,
   % Test if G = (1+TOL)*GMIN qualifies as upper bound
   g = (1+tol) * gmin;
   % Compute finite eigenvalues of symplectic pencil
   heigs = speig(a,b,c/g,d/g,e);
   mag = abs(heigs);
   % Detect unit-circle eigenvalues
   uceig = heigs(abs(1-mag) < toluc2+toluc1*max(mag));

   % Compute frequencies where gain G is attained and
   % generate new test frequencies
   ang = angle(uceig);
   ang = unique(max(eps,ang(ang>0)));
   lan0 = length(ang);
   if lan0==0
      % No unit-circle eigenvalues for G = GMIN*(1+TOL): we're done
      gpeak = gmin;  break
   else
      if lan0==1
         % Peak width below machine precision or high multiplicity of
         % Symplectic eig compromised pairing. Use ANG as test freq.
         ang = [ang,ang]; %#ok<AGROW>
      end
      lan = length(ang);
   end
   
   % Form the vector of mid-points and compute
   % gain at new test frequencies
   gmin0 = gmin;   % save current lower bound
   testz = exp(1i*(ang(1:lan-1)+ang(2:lan))/2);
   for ct=1:lan-1
      z = testz(ct);
      gw = LocalSafeNorm(d+(cc/(z*ee-aa))*bb);
      if ~isfinite(gw)
         % Singularity
         gpeak = Inf;  fpeak = abs(angle(z))/Ts;  return
      elseif gw > gmin,
         gmin = gw;  fpeak = abs(angle(z));
      end
   end

   % If lower bound has not improved, exit (safeguard against undetected
   % unit-circle eigenvalues).
   if lan0<2 || gmin<gmin0*(1+tol/10)
      gpeak = gmin;  break
   end
   iter = iter+1;
end
fpeak = fpeak/Ts;


%------------------------------------------------------------------------

function g = LocalSafeNorm(m)
% NORM() without "NaN or Inf prevents convergence" errors
if hasInfNaN(m)
   g = Inf;
else
   g = norm(m);
end

