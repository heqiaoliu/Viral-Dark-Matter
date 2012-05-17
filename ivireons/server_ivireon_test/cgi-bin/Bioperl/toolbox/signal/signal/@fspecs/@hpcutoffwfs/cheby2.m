function Hd = cheby2(this, varargin)
%CHEBY2 Chebyshev Type II digital filter design.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:32:20 $

N = this.FilterOrder;

nfreq = get(this, 'NormalizedFrequency');
normalizefreq(this, true);

Fc = this.F3db;
Fst = this.Fstop;

normalizefreq(this, nfreq);

if Fst > Fc,
    error(generatemsgid('invalidSpec'), 'Fstop must be less than Fcutoff.');
end

% Compute analog frequency
Wc = 1/tan(pi*Fc/2);

% Determine analog stopband edge frequency
Wst = 1/tan(pi*Fst/2);

% Find estop, Astop
est = cosh(N*acosh(Wst/Wc));
Ast = 10*log10(est^2+1);

% Convert to highpass with stopband-edge specifications
hs = fspecs.hpstop(N,Fst,Ast);

Hd = cheby2(hs,varargin{:});

% [EOF]
