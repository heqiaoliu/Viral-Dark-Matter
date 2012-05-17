function Hd = cheby1(this, varargin)
%CHEBY1 Chebyshev Type I digital filter design.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:32:13 $

N = this.FilterOrder;

nfreq = get(this, 'NormalizedFrequency');
normalizefreq(this, true);

Fc = this.F3dB;
Fp = this.Fpass;

normalizefreq(this, nfreq);

if Fp < Fc,
    error(generatemsgid('invalidSpec'), 'Fpass must be greater than Fcutoff.');
end

% Compute analog frequency
Wc = 1/tan(pi*Fc/2);

% Determine analog passband edge frequency
Wp = 1/tan(pi*Fp/2);

% Find epass, Apass
ep = 1/cosh(N*acosh(Wc/Wp));
Ap = 10*log10(ep^2+1);

% Convert to highpass with passband-edge specifications
hs = fspecs.hppass(N,Fp,Ap);

Hd = cheby1(hs,varargin{:});

% [EOF]
