function Hd = cheby1(this, varargin)
%CHEBY1 Chebyshev Type I digital filter design.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:33:47 $

N  = this.FilterOrder;

nfreq = get(this, 'NormalizedFrequency');
normalizefreq(this, true);

Fc = this.F3dB;
Fp = this.Fpass;

normalizefreq(this, nfreq);

if Fp > Fc,
    error(generatemsgid('invalidSpec'), 'Fpass must be less than Fcutoff.');
end

% Compute analog frequency
Wc = tan(pi*Fc/2);

% Determine analog passband edge frequency
Wp = tan(pi*Fp/2);

% Find epass, Apass
ep = 1/cosh(N*acosh(Wc/Wp));
Ap = 10*log10(ep^2+1);

% Convert to lowpass with passband-edge specifications
hs = fspecs.lppass(N,Fp,Ap);

Hd = cheby1(hs,varargin{:});


% [EOF]
