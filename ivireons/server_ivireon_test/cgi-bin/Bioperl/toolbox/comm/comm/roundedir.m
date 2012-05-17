function h = roundedir(fd, coeff, Noversampling, t)
%ROUNDEDIR  Rounded Doppler filter impulse response.
%   H = ROUNDEDIR(FD, T) returns the impulse response of a rounded Doppler
%   filter.  FD is the maximum Doppler shift (in Hz). COEFF is a vector of
%   coefficients characterizing the rounded spectrum. NOVERSAMPLING is used
%   in determining the accuracy of the impulse response. T is a vector of
%   time-domain values.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:36:21 $

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
    coeff(1) + coeff(2)*(i_Sd*f_Sd/fd).^2 + coeff(3)*(i_Sd*f_Sd/fd).^4;
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

