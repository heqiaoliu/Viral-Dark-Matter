function [a, b] = d2d(phi, gamma, t1, t2)
%D2D  Resamples discrete-time dynamic system.
%
%   SYS = D2D(SYS,TS,METHOD) resamples the discrete-time dynamic system SYS
%   to the new sampling time TS. The string METHOD selects the resampling 
%   method among the following:
%      'zoh'       Zero-order hold on the inputs
%      'tustin'    Bilinear (Tustin) approximation
%   The default is 'zoh' when METHOD is omitted.
%
%   D2D(SYS,TS,OPTIONS) gives access to additional resampling options. Use 
%   D2DOPTIONS to create and configure the option set OPTIONS. For example, 
%   you can specify a prewarping frequency for the Tustin method by:
%      opt = d2dOptions('Method','tustin','PrewarpFrequency',0.5);
%      sys = d2d(sys,0.1,opt);
%
%   See also D2DOPTIONS, D2C, C2D, DYNAMICSYSTEM/UPSAMPLE, DYNAMICSYSTEM.

%Old help
%D2D	Conversion of discrete state-space models to models with diff. sampling times.
%	[A2, B2] = D2D(A1, B1, T1, T2)  converts the discrete-time system:
%
%		x[n+1] = A1 * x[n] + B1 * u[n]
%
%	with a sampling rate of T1 to a discrete system with a sampling rate of T2.
%	The method is accurate for constant inputs. For non-integer multiples of T1
%	and T2, D2D may return complex A and B matrices. 
%
%	See also D2C and C2D.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $ $Date: 2010/03/31 18:13:19 $
%	Andrew C. W. Grace 2-20-91

error(nargchk(4,4,nargin));
error(abcdchk(phi,gamma));

[m,n] = size(phi);
[m,nb] = size(gamma);

nz = nb;
nonzero = 1:nb;

s = [[phi gamma(:,nonzero)]; zeros(nz,n) eye(nz)]^(t2/t1);
a = s(1:n,1:n);
if length(nonzero)
	b(:,nonzero) = s(1:n,n+1:n+nz);
end
