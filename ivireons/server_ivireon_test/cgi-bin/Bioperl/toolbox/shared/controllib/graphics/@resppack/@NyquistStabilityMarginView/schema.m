function schema
%  SCHEMA  Defines properties for @NyquistStabilityMarginView class

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:18:54 $

% Register class
pkg = findpackage('resppack');
c = schema.class(pkg, 'NyquistStabilityMarginView', ...
   pkg.findclass('StabilityMarginView'));