function h = ajakesir(fd, freqMinMax, Noversampling, t)
%AJAKESIR  AJakes Doppler filter impulse response.
%   H = AJAKESIR(FD, T) returns the impulse response of an asymmetrical Jakes (AJakes) Doppler
%   filter.  FD is the maximum Doppler shift (in Hz). FREQMINMAX is a
%   vector containing the minimum and maximum frequencies of the AJakes
%   Doppler spectrum, normalized to FD. NOVERSAMPLING is used in
%   determining the impulse response. T is a vector of time-domain values.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $Date: 2007/05/14 15:00:36 $

M = length(t);
fmin_ajakes = freqMinMax(1)*fd;
fmax_ajakes = freqMinMax(2)*fd;

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
Sd(Nsamples_Sd-floor(Nsamples_Sd/Noversampling/2)+1:Nsamples_Sd) = ...
    fliplr(Sd(1:1:floor(Nsamples_Sd/Noversampling/2)));

if fmin_ajakes>=0 && fmax_ajakes>=0
    % PSD is asymmetric: positive frequencies
    fmin_pos_ajakes = fmin_ajakes;
    fmax_pos_ajakes = fmax_ajakes;
    % If fmax_ajakes=fd, Sd(floor(Nsamples_Sd/Noversampling/2)) shouldn't
    % be zero
    Sd( floor(Nsamples_Sd/Noversampling/2*(fmax_pos_ajakes/fd)) + 1 : floor(Nsamples_Sd/Noversampling/2) ) = 0;
    % If fmin_ajakes=0, Sd(1) shouldn't be zero
    Sd( 1 : ceil(Nsamples_Sd/Noversampling/2*(fmin_pos_ajakes/fd)) ) = 0;
    Sd( Nsamples_Sd - ceil(Nsamples_Sd/Noversampling/2) + 1 : Nsamples_Sd ) = 0;
    % PSD is asymmetric: negative frequencies
elseif fmin_ajakes<=0 && fmax_ajakes<=0
    fmin_neg_ajakes = fmin_ajakes;
    fmax_neg_ajakes = fmax_ajakes;
    Sd( Nsamples_Sd - ceil(Nsamples_Sd/Noversampling/2) + 1 : Nsamples_Sd - floor(Nsamples_Sd/Noversampling/2*(abs(fmin_neg_ajakes)/fd)) ) = 0;
    Sd( Nsamples_Sd - ceil(Nsamples_Sd/Noversampling/2*abs(fmax_neg_ajakes)/fd) + 1 : Nsamples_Sd ) = 0;
    Sd( 1 : floor(Nsamples_Sd/Noversampling/2) ) = 0;
else
    % PSD is asymmetric: both negative and positive frequencies
    fmin_neg_ajakes = fmin_ajakes;
    fmax_pos_ajakes = fmax_ajakes;
    Sd( Nsamples_Sd - ceil(Nsamples_Sd/Noversampling/2) + 1 : Nsamples_Sd - floor(Nsamples_Sd/Noversampling/2*(abs(fmin_neg_ajakes)/fd)) ) = 0;
    Sd( floor(Nsamples_Sd/Noversampling/2*(fmax_pos_ajakes/fd)) + 1 : floor(Nsamples_Sd/Noversampling/2) ) = 0;
end

hr = fftshift(ifft(sqrt(Sd),Nsamples_Sd));
if ( floor(M/2) == M/2 )
    hr = hr(Nsamples_Sd/2-M/2+1:Nsamples_Sd/2+1+M/2-1);
else
    hr = hr(Nsamples_Sd/2-floor(M/2)+1:Nsamples_Sd/2+1+floor(M/2)+1-1);
end

% Normalized impulse response of rounded filter.
windowFcn = hamming(M).';
hrw = hr .* windowFcn;
h = hrw./sqrt(sum(abs(hrw).^2));

