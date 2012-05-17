function schema
% SCHEMA Class definition for @SpectrumView 

% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:15 $

% Find parent package
pkg = findpackage('resppack');
% Register class
superclass = findclass(findpackage('wavepack'), 'timeview');
c = schema.class(pkg, 'spectrumview', superclass);

