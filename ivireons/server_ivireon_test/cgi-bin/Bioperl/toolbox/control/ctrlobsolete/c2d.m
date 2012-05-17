function [Phi, Gamma] = c2d(a, b, t)
%C2D  Converts continuous-time dynamic system to discrete time.
%
%   SYSD = C2D(SYSC,TS,METHOD) computes a discrete-time model SYSD with 
%   sampling time TS that approximates the continuous-time model SYSC.
%   The string METHOD selects the discretization method among the following:
%      'zoh'       Zero-order hold on the inputs
%      'foh'       Linear interpolation of inputs
%      'impulse'   Impulse-invariant discretization
%      'tustin'    Bilinear (Tustin) approximation.
%      'matched'   Matched pole-zero method (for SISO systems only).
%   The default is 'zoh' when METHOD is omitted.
%
%   C2D(SYSC,TS,OPTIONS) gives access to additional discretization options. 
%   Use C2DOPTIONS to create and configure the option set OPTIONS. For 
%   example, you can specify a prewarping frequency for the Tustin method by:
%      opt = c2dOptions('PrewarpFrequency',.5);
%      sysd = c2d(sysc,.1,opt);
%
%   For state-space models without delays,
%      [SYSD,G] = C2D(SYSC,Ts,METHOD)
%   also returns the matrix G mapping the states xc(t) of SYSC to the states 
%   xd[k] of SYSD:
%      xd[k] = G * [xc(k*Ts) ; u[k]]
%   Given some initial condition x0 for SYSC, an equivalent initial condition 
%   for SYSD is
%      xd[0] = G * [x0;u0]
%   where u0 is the initial input value.
%
%   See also C2DOPTIONS, D2C, D2D, DYNAMICSYSTEM.

%Other syntax
%C2D	Conversion of state space models from continuous to discrete time.
%	[Phi, Gamma] = C2D(A,B,T)  converts the continuous-time system:
%		.
%		x = Ax + Bu
%
%	to the discrete-time state-space system:
%
%		x[n+1] = Phi * x[n] + Gamma * u[n]
%
%	assuming a zero-order hold on the inputs and sample time T.
%
%	See also D2C.

%	J.N. Little 4-21-85
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.6 $  $Date: 2010/02/08 22:30:00 $

error(nargchk(3,3,nargin));
error(abcdchk(a,b));

[m,n] = size(a); %#ok<ASGLU>
[m,nb] = size(b); %#ok<ASGLU>
s = expm([[a b]*t; zeros(nb,n+nb)]);
Phi = s(1:n,1:n);
Gamma = s(1:n,n+1:n+nb);

% end c2d
