function has = tospecifyord(h,hasmin)
%TOSPECIFYORD   Convert from minimum-order to specify order.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2007/12/14 15:17:26 $

% Get values from objects
wp = hasmin.Wpass;
ws = hasmin.Wstop;
rp = hasmin.Apass;
rs = hasmin.Astop;

str = h.MatchExactly;

eratio = sqrt((10^(rs/10)-1)/(10^(rp/10)-1));

w = ws/wp;

N = ceil(acosh(eratio)/acosh(w)); 

% Compute revised ripple
switch str,
    case 'passband',
        rs = 10*log10(1+(10^(rp/10)-1)*(cosh(N*acosh(w))^2));
        
    case 'stopband',
        % Do nothing
    otherwise
        error(generatemsgid('InvalidParam'),'Unrecognized excess order string specified.');
end

% Bandpass and bandstop filters must double the filter order
if doubleord(h), N = 2*N; end

if any(strcmpi(h.FilterStructure,{'cascadeallpass','cascadewdfallpass'})),
    % allpass implementation may require order to be increased
    N = modifyord(h,N); 
end

has = fspecs.alpstop(N,ws,rs);


% [EOF]
