function Dc = utInvDiscretizeZOH(Dd)
% Conversion of discrete explicit state-space model to continuous time 
% using ZOH method.
%
% Note:: Assumes zero internal delays have already been eliminated

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:05 $
Ts = Dd.Ts;

% Convert H(z)->H(s). This is exact whenever Dd is equivalent to
%     x[k+1]= a x + sum Bj u[k-Nj]
%     y = sum Cj x[k-Nj] + Dj u[k-Nj]
if ~isExplicitODE(Dd)
    ctrlMsgUtils.warning('Control:transformation:D2cAccuracy1')
end

% Data and sizes
% Note: Assumes E=[]
a = Dd.a;  b = Dd.b;  c = Dd.c;
nx0 = size(a,1);
nx = nx0;
nfd = length(Dd.Delay.Internal);
ny = size(c,1)-nfd;
nu = size(b,2)-nfd;
RealFlag = isreal(a) && isreal(b) && isreal(c);
StateName = Dd.StateName;
StateUnit = Dd.StateUnit;

% Compute Schur form of A
[s,p,as] = balance(a);  % eig-like pre-scaling
[u,t] = schur(as);
v = ordeig(t);  % Must come in same order as Schur vectors U

% Cannot handle poles at z=0
% REVISIT: when ordered Real Schur form is available, could map these
% to input delays
if any(abs(v)<sqrt(eps)),
    ctrlMsgUtils.error('Control:transformation:ZOHConversion1')
end

% Detect real negative poles -r and replace each of them by a
% pair of poles -r+j*pert, -r-j*pert and a zero near -r
inr = find(imag(v)==0 & real(v)<0);
lnr = length(inr);
if RealFlag && lnr>0,
   % Implicitly augment the state matrix A to create pairs of eigenvalues
   % -r+j*pert, -r-j*pert for each -r<0
   %       [T1  *  * ]        [T1   *   *    0   ]
   %   T = [ 0 -r  * ]  -->   [ 0  -r   *  -pert ]
   %       [ 0  0 T2 ]        [ 0   0  T2    0   ]
   %                          [ 0 pert  0   -r   ]
   % where pert is a small perturbation
   vnr = v(inr);
   pert = 10 * sqrt(eps) * abs(vnr);
   apert = zeros(nx,lnr);
   apert(inr,:) = diag(pert);
   apert = u(p,:) * apert;
   a = [a  lrscale(apert,s,[]) ; lrscale(-apert',[],1./s) diag(vnr)];

   % Update b and c
   b = [b ; zeros(lnr,nu+nfd)];
   c = [c ,  zeros(ny+nfd,lnr)];
   nx = nx + lnr;
   if ~isempty(StateName)
      StateName = [StateName ; repmat({''},lnr,1)];
   end
   if ~isempty(StateUnit)
      StateUnit = [StateUnit ; repmat({''},lnr,1)];
   end

   % Issue warning
   ctrlMsgUtils.warning('Control:transformation:D2cRealNegativePole')
end

% Get state equation matrices
[M,exitflag] = utScaledLogm([a b;zeros(nu+nfd,nx) eye(nu+nfd)]);
if exitflag
    ctrlMsgUtils.warning('Control:transformation:D2cAccuracy2')
end
if RealFlag
   M = real(M)/Ts;
else
   M = M/Ts;
end

% Store data
Dc = ltipack.ssdata(M(1:nx,1:nx),M(1:nx,nx+1:nx+nu+nfd),c,Dd.d,[],0);
Dc.StateName = StateName;
Dc.StateUnit = StateUnit;
Dc.Delay.Input = Ts * Dd.Delay.Input;
Dc.Delay.Output = Ts * Dd.Delay.Output;
Dc.Delay.Internal = Ts * Dd.Delay.Internal;

