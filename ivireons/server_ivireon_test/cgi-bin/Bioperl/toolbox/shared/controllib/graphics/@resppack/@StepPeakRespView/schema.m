function schema
%SCHEMA  Defines properties for @StepPeakRespView class

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:29 $

% Find parent package
pkg = findpackage('resppack');

% Find parent class (superclass)
supclass = findclass(findpackage('wavepack'), 'TimePeakAmpView');

% Register class (subclass)
c = schema.class(pkg, 'StepPeakRespView', supclass);