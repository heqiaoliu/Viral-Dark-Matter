function Hd = cheby2(this, varargin)
%CHEBY2 Chebyshev Type II digital filter design.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:33:36 $

N = this.FilterOrder;
Fs = this.Fs;
Fc = this.F3dB;
Ast = this.Astop;

% Compute analog frequency
if this.NormalizedFrequency,
    Wc = tan(pi*Fc/2);
else
    Wc = tan(pi*Fc/Fs);
end

% Find corresponding analog stopband-edge frequency
Wst = Wc*cosh(1/N*acosh(sqrt(10^(Ast/10)-1)));

% Convert analog stopband-edge frequency to digital
Fst = 2*atan(Wst)/pi;

% Construct a new fdesign object with the converted specs
Hdes2 = fdesign.lowpass('N,Fst,Ast',N,Fst,Ast);

Hd = cheby2(Hdes2,varargin{:});

% [EOF]
