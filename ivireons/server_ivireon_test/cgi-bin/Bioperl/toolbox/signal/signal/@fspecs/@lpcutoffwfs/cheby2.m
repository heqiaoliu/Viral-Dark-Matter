function Hd = cheby2(this, varargin)
%CHEBY2 Chebyshev Type II digital filter design.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:33:55 $

N = this.FilterOrder;

nfreq = get(this, 'NormalizedFrequency');
normalizefreq(this, true);

Fc  = this.F3dB;
Fst = this.Fstop;

normalizefreq(this, nfreq);

if Fst < Fc,
    error(generatemsgid('invalidSpec'), 'Fstop must be greater than Fcutoff.');
end

% Compute analog frequency
Wc = tan(pi*Fc/2);

% Determine analog stopband edge frequency
Wst = tan(pi*Fst/2);

% Find estop, Astop
est = cosh(N*acosh(Wst/Wc));
Ast = 10*log10(est^2+1);

% Construct a new fdesign object with the converted specs
hs = fspecs.lpstop(N, Fst, Ast);

Hd = cheby2(hs,varargin{:});

% [EOF]
