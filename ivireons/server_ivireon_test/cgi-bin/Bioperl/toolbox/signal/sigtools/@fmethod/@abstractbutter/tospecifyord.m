function has = tospecifyord(h,hasmin)
%TOSPECIFYORD   Convert from minimum-order to specify order.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2007/12/14 15:17:23 $

% Get values from objects
wp = hasmin.Wpass;
ws = hasmin.Wstop;
rp = hasmin.Apass;
rs = hasmin.Astop;

str = h.MatchExactly;

eratio = sqrt((10^(rs/10)-1)/(10^(rp/10)-1));

w = ws/wp;

N = ceil(log(eratio)/log(w));

% Compute cutoff freq
switch str,
    case 'passband',
        wc = wp/sqrt(10^(rp/10)-1)^(1/N);
    case 'stopband',
        wc = ws/sqrt(10^(rs/10)-1)^(1/N);
    otherwise
        error(generatemsgid('InvalidParam'),'Unrecognized excess order string specified.');
end

% Bandpass and bandstop filters must double the filter order
if doubleord(h), N = 2*N; end

if any(strcmpi(h.FilterStructure,{'cascadeallpass','cascadewdfallpass'})),
    % allpass implementation may require order to be increased 
    N = modifyord(h,N); 
end

has = fspecs.alpcutoff(N,wc);


% [EOF]
