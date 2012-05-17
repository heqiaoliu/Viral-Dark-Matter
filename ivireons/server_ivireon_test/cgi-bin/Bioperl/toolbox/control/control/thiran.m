function sysf = thiran(tau,Ts)
%THIRAN  Thiran approximation of fractional discrete-time delays.
%
%   SYS = THIRAN(TAU,TS) discretizes the continuous-time delay TAU using a
%   Thiran filter to approximate the fractional part of the delay. TS
%   specifies the sampling time and the output SYS is a transfer function
%   (see TF).
%
%   If TAU is a multiple of TS, SYS is the pure discrete delay z^-N with
%   N=TAU/TS. Otherwise, SYS is a discrete-time all-pass IIR filter of
%   order CEIL(TAU/TS).
%
%   See also C2D, TF.

%   Author(s): Murad Abu-Khalaf, September 11, 2009
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2009/11/09 16:17:46 $

% Error checking
ni = nargin;
error(nargchk(2,2,ni));
if ~(isnumeric(Ts) && isscalar(Ts) && Ts >0)   % isPositiveScalar
    ctrlMsgUtils.error('Control:transformation:thiran01');
end
if ~(isnumeric(tau) && isscalar(tau) && tau >=0) % isNonNegativeScalar
    ctrlMsgUtils.error('Control:transformation:thiran02');
end

% Get Thiran filter coefficients
[num,den] = thirancoef(tau,Ts);

% Return TF
sysf = tf(num,den,Ts);