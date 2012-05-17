function schema
%SCHEMA  Defines properties for @BodeStabilityMarginView class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:18:19 $

% Register class
pkg = findpackage('resppack');
c = schema.class(pkg, 'BodeStabilityMarginView', pkg.findclass('StabilityMarginView'));
