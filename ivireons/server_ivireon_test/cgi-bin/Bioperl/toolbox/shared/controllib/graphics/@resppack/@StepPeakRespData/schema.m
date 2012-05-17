function schema
%  SCHEMA  Defines properties for @StepPeakRespData class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:26 $

% Find parent package
pkg = findpackage('resppack');

% Find parent class (superclass)
supclass = findclass(findpackage('wavepack'), 'TimePeakAmpData');

% Register class (subclass)
c = schema.class(pkg, 'StepPeakRespData', supclass);

% Public attributes
schema.prop(c, 'OverShoot', 'MATLAB array'); % OverShoot Data