function schema
%SCHEMA  Defines properties for @SpectrumHarmonicView class

% Author(s): Erman Korkut 18-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:27:03 $

% Register class (subclass)
superclass = findclass(findpackage('wavepack'), 'FreqPeakGainView');
c = schema.class(findpackage('wavepack'), 'SpectrumHarmonicView', superclass);
