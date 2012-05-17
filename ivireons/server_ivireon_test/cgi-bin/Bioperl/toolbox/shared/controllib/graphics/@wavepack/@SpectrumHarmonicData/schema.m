function schema
%SCHEMA  Defines properties for @SpectrumHarmonicData class

% Author(s): Erman Korkut 25-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:27:00 $

% Register class (subclass)
superclass = findclass(findpackage('wavepack'), 'FreqPeakGainData');
c = schema.class(findpackage('wavepack'), 'SpectrumHarmonicData', superclass);
