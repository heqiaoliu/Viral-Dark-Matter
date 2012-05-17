function schema
%  SCHEMA  Defines properties for @TimeInitialValueData class

%  Author(s): Erman Korkut 25-Mar-2009
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:20:01 $

% Register class
superclass = findclass(findpackage('resppack'), 'TimeFinalValueData');
c = schema.class(findpackage('resppack'), 'TimeInitialValueData', superclass);

