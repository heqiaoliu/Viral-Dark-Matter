function schema
%SCHEMA  Defines properties for @OperatingPoint class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/04/25 03:19:41 $

% Find the package
pkg = findpackage('opcond');

% Find parent class (superclass)
supclass = findclass(pkg, 'AbstractOperatingPoint');

% Register class
c = schema.class(pkg, 'OperatingPoint', supclass);