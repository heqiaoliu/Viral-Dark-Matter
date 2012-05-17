function h = bellir(fd, coeff, Noversampling, t)
%BELLIR  Bell Doppler filter impulse response.
%   H = BELLIR(FD, T) returns the impulse response of a bell Doppler
%   filter.  FD is the maximum Doppler shift (in Hz). COEFF is a positive,
%   real finite scalar coefficient characterizing the bell spectrum.
%   NOVERSAMPLING is used in determining the accuracy of the impulse
%   response. T is a vector of time-domain values.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/09/13 06:45:55 $

LR = length(t);
M = LR;

Nsamples_Sd = floor(Noversampling*M);
if ( floor(Nsamples_Sd/2) == Nsamples_Sd/2 )
    %
else
    Nsamples_Sd = Nsamples_Sd + 1;
end
Sd = zeros(1,Nsamples_Sd);
f_Sd = Noversampling*(2*fd)/(Nsamples_Sd);
i_Sd = 1:1:floor(Nsamples_Sd/Noversampling/2);
Sd(1:1:floor(Nsamples_Sd/Noversampling/2)) = ...
    1./ (1 + coeff*(i_Sd*f_Sd/fd).^2 );
Sd(Nsamples_Sd-floor(Nsamples_Sd/Noversampling/2)+1:Nsamples_Sd) = ...
    fliplr(Sd(1:1:floor(Nsamples_Sd/Noversampling/2)));

hr = fftshift(real(ifft(sqrt(Sd),Nsamples_Sd)));
if ( floor(M/2) == M/2 )
    hr = hr(Nsamples_Sd/2-M/2+1:Nsamples_Sd/2+1+M/2-1);
else
    hr = hr(Nsamples_Sd/2-floor(M/2)+1:Nsamples_Sd/2+1+floor(M/2)+1-1);
end

% Normalized impulse response of bell filter.
windowFcn = hamming(LR).';
hrw = hr .* windowFcn;
h = hrw./sqrt(sum(abs(hrw).^2));
