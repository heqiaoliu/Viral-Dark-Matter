function schema
%SCHEMA  Defines properties for @SigmaPeakRespData class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:07 $

% Find parent class (superclass)
supclass = findclass(findpackage('wavepack'), 'FreqPeakGainData');

% Register class (subclass)
c = schema.class(findpackage('resppack'), 'SigmaPeakRespData', supclass);
