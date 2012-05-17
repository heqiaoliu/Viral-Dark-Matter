function updateChannel(this,that,i)
%UPDATECHANNEL   

%   Copyright 2006-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/05/14 15:02:28 $

% Do error checking on SigmaGaussian: should be <
% 1/(Noversampling*Ts*fd*sqrt(2*log2(2))) so that the interpolation factor
% is greater than 1
if ( this.SigmaGaussian >= ...
        1/(10*sqrt(2*log(2))*that.MaxDopplerShift*that.InputSamplePeriod) )
    this.SigmaGaussian = 0.99 * ...
        1/(10*sqrt(2*log(2))*that.MaxDopplerShift*that.InputSamplePeriod);
    warning('comm:dopplerGaussian:SigmaGaussian', ...
        ['SigmaGaussian must be less than 1/(10*sqrt(2*log(2))*fd*Ts),' ...
        ' where fd is the maximum Doppler shift and Ts is the input sample period.' ...
        ' It has been set to 0.99 times this value.'])
end
that.RayleighFading.FiltGaussian.DopplerSpectrum(i).SigmaGaussian = this.SigmaGaussian;
that.RayleighFading.CutoffFrequencyFactor(i) = this.SigmaGaussian * sqrt(2*log(2));
% Forces initialization of RayleighFading and FiltGaussian
that.RayleighFading.CutoffFrequency(i) = that.MaxDopplerShift * ...
    that.RayleighFading.CutoffFrequencyFactor(i);
that.initialize;