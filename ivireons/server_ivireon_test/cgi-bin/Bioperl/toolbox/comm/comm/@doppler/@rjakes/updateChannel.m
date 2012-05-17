function updateChannel(this,that,i)
%UPDATECHANNEL   
%
%   Inputs:
%       this:   handle to Doppler spectrum object contained in multipath object
%       that:   handle to multipath object

%   Copyright 2006-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/05/14 15:02:31 $


if ( this.FreqMinMaxRJakes(2)- this.FreqMinMaxRJakes(1) <=  1/50 )
    this.FreqMinMaxRJakes = [0 1];
    warning('comm:dopplerRJakes:FreqMinMaxRJakes', ...
        ['The minimum and maximum frequencies (normalized by the maximum Doppler shift)' ... 
            ' for the RJakes doppler spectrum should be spaced by more than 1/50,' ...
            ' FreqMinMaxRJakes has been reset to [0 1].'])
end
that.RayleighFading.FiltGaussian.DopplerSpectrum(i).FreqMinMaxRJakes = this.FreqMinMaxRJakes;
that.RayleighFading.FiltGaussian.initialize;
that.initialize;
