function [aa,bb,cc,dd] = thirancoef(tau,Ts)
%THIRANCOEF  Thiran filter for fractional delays.
%
%   [NUM,DEN] = THIRANCOEF(TAU,Ts) discretizes the continuous-time delay
%   TAU according to the sample time Ts. The result is the numerator and
%   denominator of the discrete-time all-pass IIR filter that can also
%   handle fractional delays.
%
%   [A,B,C,D] = THIRANCOEF(TAU,Ts) returns the state-space realization of
%   the discrete-time Thiran filter, while [Z,P,K] = THIRANCOEF(TAU,Ts)
%   returns the Zero/Pole/Gain values.
%
%   For TAU = n*Ts, n=0,1,2,..., THIRANCOEF returns the coefficients of the
%   pure discrete delay, z^-n.

%   Author(s): Murad Abu-Khalaf, September 2, 2009
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 04:47:38 $

% Error checking
ni = nargin;
no = nargout;
error(nargchk(2,2,ni));

% Extract D and N.
D = tau/Ts;
N = ceil(D);
d = D-N;

%  Returns the Nth order Thiran allpass interpolation filter.
%    a[k]   = - (D-N+(k-1))/k * (N-(k-1))/(D+k) * a[k-1]
%    a[0]   = 1, and k = 1,2,...,N.

k  = 1:N;
gk = - (((d-1)+k)./k) .* (fliplr(k)./(D+k));
a  = [1 cumprod(gk)];

den = a;
num = fliplr(den);

if no<=2
    % Return num, den of transfer function
    aa = num;
    bb = den;
elseif no==3
    % Return Z,P,K
    bb = roots(den);   % Poles:
    aa = 1./bb(bb~=0); % Zeros: (aa = roots(num)) Handles zero roots when D-N=0
    cc = num(find(num,1)); % K: % Handles num =[0 0 0 .. 1] when D-N=0
else
    % Return a, b, c, d
    [aa,bb,cc,dd] = compreal(num,den);
end
