function schema
%SCHEMA  Defines properties for @NicholsStabilityMarginView class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:18:43 $

% Register class
pkg = findpackage('resppack');
c = schema.class(pkg, 'NicholsStabilityMarginView', ...
   pkg.findclass('StabilityMarginView'));