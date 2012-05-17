function schema
%SCHEMA  Defines properties for @SigmaPeakRespView class

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:11 $

% Register class (subclass)
wpack = findpackage('wavepack');
c = schema.class(findpackage('resppack'), ...
   'SigmaPeakRespView', findclass(wpack, 'FreqPeakGainView'));