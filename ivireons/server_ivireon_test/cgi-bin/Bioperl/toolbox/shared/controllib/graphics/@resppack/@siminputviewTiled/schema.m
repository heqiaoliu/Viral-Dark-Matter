function schema
%SCHEMA  Defines properties for @siminputview class

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:39 $

% Parent class
pc = findclass(findpackage('wavepack'), 'timeview');

% Register class (subclass)
c = schema.class(findpackage('resppack'), 'siminputviewTiled',pc);
