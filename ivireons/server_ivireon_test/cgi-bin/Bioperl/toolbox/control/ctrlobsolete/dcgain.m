function k = dcgain(a,b,c,d)
%DCGAIN  DC gain of dynamic systems.
%
%   K = DCGAIN(SYS) computes the steady-state (D.C. or low frequency) gain
%   of the dynamic system SYS.
%
%   If SYS is an array of dynamic systems with dimensions [NY NU S1 ... Sp],
%   DCGAIN returns an array K with the same dimensions such that
%      K(:,:,j1,...,jp) = DCGAIN(SYS(:,:,j1,...,jp)) .
%
%   See also DYNAMICSYSTEM/NORM, DYNAMICSYSTEM/EVALFR, FREQRESP, DYNAMICSYSTEM.

% Old help
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%DCGAIN D.C. gain of continuous system.
%	K = DCGAIN(A,B,C,D) computes the steady state (D.C. or low 
%	frequency) gain of the continuous state-space system (A,B,C,D).
%
%	K = DCGAIN(NUM,DEN) computes the steady state gain of the 
%	continuous polynomial transfer function system G(s)=NUM(s)/DEN(s)
%	where NUM and DEN contain the polynomial coefficients in 
%	descending powers of s.
%
%	See also: DDCGAIN.

%	Clay M. Thompson  7-6-90
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.1.8.3 $  $Date: 2010/03/31 18:13:20 $

ni = nargin;

if ni==2, 
  % Transfer function description NUM,DEN
  k = dcgain(tf(a,b));
elseif ni==4, 
  % State space description A,B,C,D
  k = dcgain(ss(a,b,c,d));
else
  error('Wrong number of input arguments.');
end
