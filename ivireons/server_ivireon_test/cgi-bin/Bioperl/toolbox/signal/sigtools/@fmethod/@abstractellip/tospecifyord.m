function has = tospecifyord(h,hasmin)
%TOSPECIFYORD   Convert from minimum-order to specify order.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2006/06/27 23:38:25 $

% Get values from objects
Wp = hasmin.Wpass;
Ws = hasmin.Wstop;
Apass = hasmin.Apass;
Astop = hasmin.Astop;

% Compute cutoff
Wc=sqrt(Wp*Ws);

% Normalize passband-edge
Wpc = Wp/Wc;

% Determine min order
q = computeq(h,Wpc);
D = (10^(0.1*Astop) - 1)/(10^(0.1*Apass) - 1);
N = ceil(log10(16*D)/log10(1/q));

switch h.MatchExactly,
    case 'passband',
        % Stopband attenuation can be found from
        Astop = 10*log10((10^(.1*Apass) - 1)/(16*q^N) + 1);
    case 'stopband',
        Apass = 10*log10(16*(q^N)*(10^(.1*Astop)-1)+1);
    case 'both',
        % Do nothing
end

% Bandpass and bandstop filters must double the filter order
if doubleord(h), N = 2*N; end

if any(strcmpi(h.FilterStructure,{'cascadeallpass','cascadewdfallpass'})),
    % allpass implementation may require order to be increased 
    N = modifyord(h,N); 
end

has = fspecs.alppassastop(N,Wp,Apass,Astop);


% [EOF]
