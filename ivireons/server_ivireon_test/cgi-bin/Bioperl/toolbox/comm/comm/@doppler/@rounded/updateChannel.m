function updateChannel(this,that,i)
%UPDATECHANNEL   
%
%   Inputs:
%       this:   handle to Doppler spectrum object contained in multipath object
%       that:   handle to multipath object

%   Copyright 2006-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/05/14 15:02:33 $


that.RayleighFading.FiltGaussian.DopplerSpectrum(i).CoeffRounded = this.CoeffRounded;
that.RayleighFading.FiltGaussian.initialize;
that.initialize;
