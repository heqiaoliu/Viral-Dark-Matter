function updateChannel(this,that,i)
%UPDATECHANNEL   
%
%   Inputs:
%       this:   handle to Doppler spectrum object contained in multipath object
%       that:   handle to multipath object

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:02:22 $


if ( this.FreqMinMaxAJakes(2)- this.FreqMinMaxAJakes(1) <=  1/50 )
    this.FreqMinMaxAJakes = [0 1];
    warning('comm:dopplerAJakes:FreqMinMaxAJakes', ...
        ['The minimum and maximum frequencies (normalized by the maximum Doppler shift)' ... 
            ' for the AJakes doppler spectrum should be spaced by more than 1/50,' ...
            ' FreqMinMaxAJakes has been reset to [0 1].'])
end
that.RayleighFading.FiltGaussian.DopplerSpectrum(i).FreqMinMaxAJakes = this.FreqMinMaxAJakes;
that.RayleighFading.FiltGaussian.initialize;
that.initialize;
