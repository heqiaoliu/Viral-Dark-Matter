function updateChannel(this, that, i)
%UPDATECHANNEL   
%
%   Inputs:
%       this:   handle to Doppler spectrum object contained in channel object
%       that:   handle to channel object

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/09/13 06:46:15 $

that.RayleighFading.FiltGaussian.DopplerSpectrum(i).CoeffBell = this.CoeffBell;
that.RayleighFading.FiltGaussian.initialize;
that.initialize;
