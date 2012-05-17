function schema
%SCHEMA  Defines properties for @SimInputPeakView class.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:14 $

% Register class
superclass = findclass(findpackage('wavepack'), 'TimePeakAmpView');
c = schema.class(findpackage('resppack'), 'SimInputPeakView', superclass);
