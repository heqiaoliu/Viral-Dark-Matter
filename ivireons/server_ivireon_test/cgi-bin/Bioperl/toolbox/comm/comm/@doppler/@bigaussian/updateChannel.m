function updateChannel(this,that,i)
%UPDATECHANNEL   

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/06/08 15:52:33 $

% Retrieves properties from this (Doppler object) and that (multipath
% object), for faster access.
sigmaGaussian1 = this.SigmaGaussian1;
sigmaGaussian2 = this.SigmaGaussian2;
centerFreqGaussian1 = this.CenterFreqGaussian1;
centerFreqGaussian2 = this.CenterFreqGaussian2;
gainGaussian1 = this.GainGaussian1;
gainGaussian2 = this.GainGaussian2;

maxDopplerShift = that.MaxDopplerShift;
inputSamplePeriod = that.InputSamplePeriod;

if ( (gainGaussian1 == 0) ...
        && (centerFreqGaussian2 == 0) )
    % To cover special case where first spectrum has a zero gain and second
    % spectrum is centered around zero: equivalent to a Gaussian Doppler
    % spectrum.
    % The sampling frequency for the filtered Gaussian noise process is
    % then proportional to the cutoff frequency
    if ( sigmaGaussian2 >= 1/(10*sqrt(2*log(2))*maxDopplerShift*inputSamplePeriod) )
        this.SigmaGaussian2 = 0.99 * ...
            1/(10*sqrt(2*log(2))*maxDopplerShift*inputSamplePeriod);
        sigmaGaussian2 = this.SigmaGaussian2;
        warning('comm:dopplerBigaussian:SigmaGaussian2', ...
            ['SigmaGaussian2 must be less than 1/(10*sqrt(2*log(2))*fd*Ts),' ...
            ' where fd is the maximum Doppler shift and Ts is the input sample period.\n' ...
            'It has been set to 0.99 times this value.'])
    end
    % CutoffFrequencyFactor is used in RayleighFading to recompute
    % CutoffFrequency when MaxDopplerShift changes.
    that.RayleighFading.CutoffFrequencyFactor(i) = sigmaGaussian2 * sqrt(2*log(2));
elseif ( (gainGaussian2 == 0) ...
        && (centerFreqGaussian1 == 0) )
    % To cover special case where second spectrum has a zero gain and first
    % spectrum is centered around zero: equivalent to a Gaussian Doppler
    % spectrum.        
    % The sampling frequency for the filtered Gaussian noise process is
    % then proportional to the cutoff frequency    
    if ( sigmaGaussian1 >= 1/(10*sqrt(2*log(2))*maxDopplerShift*inputSamplePeriod) )
        this.SigmaGaussian1 = 0.99 * ...
            1/(10*sqrt(2*log(2))*maxDopplerShift*inputSamplePeriod);
        sigmaGaussian1 = this.SigmaGaussian1;
        warning('comm:dopplerBigaussian:SigmaGaussian1', ...
            ['SigmaGaussian1 must be less than 1/(10*sqrt(2*log(2))*fd*Ts),' ...
            ' where fd is the maximum Doppler shift and Ts is the input sample period.\n' ...
            'It has been set to 0.99 times this value.'])
    end
    that.RayleighFading.CutoffFrequencyFactor(i) = sigmaGaussian1 * sqrt(2*log(2));
elseif ( (centerFreqGaussian1 == 0) ...
        && (centerFreqGaussian2 == 0) ...
        && (sigmaGaussian1 == sigmaGaussian2) )
    % To cover special case where both spectra are centered around zero and
    % have the same variance: equivalent to a Gaussian Doppler spectrum.
    % The sampling frequency for the filtered Gaussian noise process is
    % then proportional to the cutoff frequency
    if ( sigmaGaussian1 >= 1/(10*sqrt(2*log(2))*maxDopplerShift*inputSamplePeriod) )
        this.SigmaGaussian1 = 0.99 * ...
            1/(10*sqrt(2*log(2))*maxDopplerShift*inputSamplePeriod);
        sigmaGaussian1 = this.SigmaGaussian1;
        this.SigmaGaussian2 = 0.99 * ...
            1/(10*sqrt(2*log(2))*maxDopplerShift*inputSamplePeriod);
        sigmaGaussian2 = this.SigmaGaussian2;
        warning('comm:dopplerBigaussian:SigmaGaussian12', ...
            ['SigmaGaussian1 and SigmaGaussian2 must be less than 1/(10*sqrt(2*log(2))*fd*Ts),' ...
            ' where fd is the maximum Doppler shift and Ts is the input sample period.\n' ...
            'They have been set to 0.99 times this value.'])
    end
    that.RayleighFading.CutoffFrequencyFactor(i) = sigmaGaussian1 * sqrt(2*log(2));
else
    % "True" bi-Gaussian case, where standard deviations are unequal
    % and/or center frequencies are nonzero.
    % The sampling frequency for the filtered Gaussian noise process is
    % then proportional to the maximum Doppler shift
    if ( abs(centerFreqGaussian1) + sigmaGaussian1*sqrt(2*log(2)) > 1 )
        this.SigmaGaussian1 = (1-abs(centerFreqGaussian1))/(sqrt(2*log(2)));
        sigmaGaussian1 = this.SigmaGaussian1;
        warning('comm:dopplerBigaussian:CenterFreqGaussian1SigmaGaussian1', ...
            ['CenterFreqGaussian1 and SigmaGaussian1 must be chosen such that' ...
            ' abs(CenterFreqGaussian1) + SigmaGaussian1*sqrt(2*log(2))) <= 1.\n' ...
            'SigmaGaussian1 has been set to its maximum permissible value, i.e.' ...
            ' (1-abs(CenterFreqGaussian1))/(sqrt(2*log(2))).']);
    elseif ( abs(centerFreqGaussian2) + sigmaGaussian2*sqrt(2*log(2)) > 1 )
        this.SigmaGaussian2 = (1-abs(centerFreqGaussian2))/(sqrt(2*log(2)));
        sigmaGaussian2 = this.SigmaGaussian2;
        warning('comm:dopplerBigaussian:CenterFreqGaussian2SigmaGaussian2', ...
            ['CenterFreqGaussian2 and SigmaGaussian2 must be chosen such that' ...
            ' abs(CenterFreqGaussian2) + SigmaGaussian2*sqrt(2*log(2))) <= 1.\n' ...
            'SigmaGaussian2 has been set to its maximum permissible value, i.e.' ...
            ' (1-abs(CenterFreqGaussian2))/(sqrt(2*log(2))).']);
    end
    that.RayleighFading.CutoffFrequencyFactor(i) = 1.0;
end
% Stores SigmaGaussian1, SigmaGaussian2, CenterFreqGaussian1,
% CenterFreqGaussian2, GainGaussian1, GainGaussian2, in private data of
% FiltGaussian so that it can be accessed upon initialization
that.RayleighFading.FiltGaussian.DopplerSpectrum(i).SigmaGaussian1 = sigmaGaussian1;
that.RayleighFading.FiltGaussian.DopplerSpectrum(i).SigmaGaussian2 = sigmaGaussian2;
that.RayleighFading.FiltGaussian.DopplerSpectrum(i).CenterFreqGaussian1 = centerFreqGaussian1;
that.RayleighFading.FiltGaussian.DopplerSpectrum(i).CenterFreqGaussian2 = centerFreqGaussian2;
that.RayleighFading.FiltGaussian.DopplerSpectrum(i).GainGaussian1 = gainGaussian1;
that.RayleighFading.FiltGaussian.DopplerSpectrum(i).GainGaussian2 = gainGaussian2;

% Forces initialization of RayleighFading and FiltGaussian
that.RayleighFading.CutoffFrequency(i) = that.RayleighFading.CutoffFrequencyFactor(i) * maxDopplerShift;
that.RayleighFading.FiltGaussian.initialize;
that.initialize;
