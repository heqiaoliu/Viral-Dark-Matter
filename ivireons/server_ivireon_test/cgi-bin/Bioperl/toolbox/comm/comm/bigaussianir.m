function h = bigaussianir(fd, ...
                            sigmaGaussian1, sigmaGaussian2, ...
                            centerFreqGaussian1, centerFreqGaussian2, ...
                            gainGaussian1, gainGaussian2, ...
                            Noversampling, t)
%BIGAUSSIANIR  Bi-Gaussian Doppler filter impulse response.
%   H = BIGAUSSIANIR(FD, SIGMAGAUSSIAN1, SIGMAGAUSSIAN2,
%   CENTERFREQGAUSSIAN1, CENTERFREQGAUSSIAN2, GAINGAUSSIAN1, GAINGAUSSIAN2,
%   NOVERSAMPLING, T) returns the impulse response of a bi-Gaussian Doppler
%   filter.  FD is the maximum Doppler shift (in Hz). SIGMAGAUSSIAN1 AND
%   SIGMAGAUSSIAN2 are the standard deviations of the Gaussian functions,
%   normalized to FD. CENTERFREQGAUSSIAN1 AND CENTERFREQGAUSSIAN2 are the
%   frequency offsets of the Gaussian functions, normalized to FD.
%   GAINGAUSSIAN1 and GAINGAUSSIAN2 are the (power) gains of the Gaussian
%   functions. NOVERSAMPLING is used in determining the impulse response. T
%   is a vector of time-domain values.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/06/08 15:51:40 $

M = length(t);

Nsamples_Sd = floor(Noversampling*M);
if ( floor(Nsamples_Sd/2) == Nsamples_Sd/2 )
    %
else
    Nsamples_Sd = Nsamples_Sd + 1;
end
f_Sd = Noversampling*(2*fd) / (Nsamples_Sd);

% In the special case where both spectra are centered around zero and have
% the same variance, the bi-Gaussian Doppler spectrum is equivalent to a
% Gaussian Doppler spectrum, and should produce the same results. In this
% case, the first argument fd of bigaussianir is actually the *cutoff
% frequency* of the Gaussian process, given by the maximum Doppler shift
% times a factor of sigmaGaussian1*sqrt(2*log(2))). We need to recover the
% actual maximum Doppler shift in order the compute the correct values of
% sigmaGaussian_1, sigmaGaussian_2, centerFreqGaussian_1 and
% centerFreqGaussian_2.
if ( ( (centerFreqGaussian1 == 0) && (centerFreqGaussian2 == 0) ) && ...
        (sigmaGaussian1 == sigmaGaussian2) )
    fd = fd / (sigmaGaussian1*sqrt(2*log(2)));   
% This is also the case if one spectrum is centered around zero and the
% other has a gain of zero.
elseif ( (gainGaussian1 == 0) && (centerFreqGaussian2 == 0) )
    fd = fd / (sigmaGaussian2*sqrt(2*log(2)));
elseif ( (gainGaussian2 == 0) && (centerFreqGaussian1 == 0) )
    fd = fd / (sigmaGaussian1*sqrt(2*log(2)));
else    
end    

% Denormalize standard deviations of Gaussian functions
sigmaGaussian1 = sigmaGaussian1 * fd;
sigmaGaussian2 = sigmaGaussian2 * fd;

% Denormalize frequency offsets of Gaussian functions
centerFreqGaussian1 = centerFreqGaussian1 * fd;
centerFreqGaussian2 = centerFreqGaussian2 * fd;

i_Sd = -ceil(Nsamples_Sd/2)+1 : 1 : floor(Nsamples_Sd/2);
Sd = gainGaussian1 * 1/(sqrt(2*pi)*sigmaGaussian1^2) ...
    * exp(-(i_Sd*f_Sd-centerFreqGaussian1).^2/(2*sigmaGaussian1^2)) ...
   + gainGaussian2 * 1/(sqrt(2*pi)*sigmaGaussian2^2) ...
    * exp(-(i_Sd*f_Sd-centerFreqGaussian2).^2/(2*sigmaGaussian2^2));       
Sd = fftshift(Sd);  % Because ifft works over [0, 2*pi]
        
hr = fftshift(ifft(sqrt(Sd), Nsamples_Sd));  % Impulse response can be complex
if ( floor(M/2) == M/2 )
    hr = hr( Nsamples_Sd/2-M/2+1 : Nsamples_Sd/2+1+M/2-1);
else
    hr = hr( Nsamples_Sd/2-floor(M/2)+1 : Nsamples_Sd/2+1+floor(M/2)+1-1 );
end

% Normalized impulse response of bi-Gaussian Doppler filter.
windowFcn = hamming(M).';
hrw = hr .* windowFcn;
h = hrw ./ sqrt(sum(abs(hrw).^2));


