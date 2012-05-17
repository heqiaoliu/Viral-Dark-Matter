function schema
%SCHEMA  Defines properties for @NyquistPeakRespView class

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:18:50 $

% Register class
superclass = findclass(findpackage('wrfc'), 'PointCharView');
c = schema.class(findpackage('resppack'), 'NyquistPeakRespView', superclass);

% Public attributes
schema.prop(c, 'Lines', 'MATLAB array');     % Dashed lines from origin to peak