function h = rjakesir(fd, freqMinMax, Noversampling, t)
%RJAKESIR  R-Jakes Doppler filter impulse response.
%   H = RJAKESIR(FD, T) returns the impulse response of a R-Jakes Doppler
%   filter.  FD is the maximum Doppler shift (in Hz). FREQMINMAX is a
%   vector containing the minimum and maximum frequencies of the R-Jakes
%   Doppler spectrum, normalized to FD. NOVERSAMPLING is used in
%   determining the impulse response. T is a vector of time-domain values.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:36:20 $

LR = length(t);
M = LR;
fmin_rjakes = freqMinMax(1)*fd;
fmax_rjakes = freqMinMax(2)*fd;

Nsamples_Sd = floor(Noversampling*M);
if ( floor(Nsamples_Sd/2) == Nsamples_Sd/2 )
    %
else
    Nsamples_Sd = Nsamples_Sd + 1;
end
Sd = zeros(1,Nsamples_Sd);
f_Sd = Noversampling*(2*fd)/(Nsamples_Sd);
i_Sd = 1:1:floor(Nsamples_Sd/Noversampling/2)-1;
Sd(1:1:floor(Nsamples_Sd/Noversampling/2)-1) = 1./(pi*fd*sqrt(1-((i_Sd*f_Sd)/fd).^2));
Sd(floor(Nsamples_Sd/Noversampling/2)) = ...
    interp1([floor(Nsamples_Sd/Noversampling/2)-2 floor(Nsamples_Sd/Noversampling/2)-1],Sd(floor(Nsamples_Sd/Noversampling/2)-2:floor(Nsamples_Sd/Noversampling/2)-1),floor(Nsamples_Sd/Noversampling/2),'cubic','extrap'); 
% If fmax_rjakes=fd, Sd(floor(Nsamples_Sd/Noversampling/2)) shouldn't be zero
Sd(floor(Nsamples_Sd/Noversampling/2*(fmax_rjakes/fd))+1:floor(Nsamples_Sd/Noversampling/2)) = 0;  
% If fmin_rjakes=0, Sd(1) shouldn't be zero
Sd(1:ceil(Nsamples_Sd/Noversampling/2*(fmin_rjakes/fd))) = 0;
Sd(Nsamples_Sd-floor(Nsamples_Sd/Noversampling/2)+1:Nsamples_Sd) = ...
    fliplr(Sd(1:1:floor(Nsamples_Sd/Noversampling/2)));

hr = fftshift(real(ifft(sqrt(Sd),Nsamples_Sd)));
if ( floor(M/2) == M/2 )
    hr = hr(Nsamples_Sd/2-M/2+1:Nsamples_Sd/2+1+M/2-1);
else
    hr = hr(Nsamples_Sd/2-floor(M/2)+1:Nsamples_Sd/2+1+floor(M/2)+1-1);
end

% Normalized impulse response of rounded filter.
windowFcn = hamming(LR).';
hrw = hr .* windowFcn;
h = hrw./sqrt(sum(abs(hrw).^2));

