function schema
%  SCHEMA  Defines properties for @UncertainTimeData class

%  Author(s): Craig Buhr
%  Revised:
%  Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/04/11 20:36:15 $

% Register class
superclass = findclass(findpackage('resppack'), 'UncertainTimeData');
c = schema.class(findpackage('resppack'), 'UncertainImpulseData', superclass);




