function schema
%SCHEMA  Class definition for @respsource (abstract response source).

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:23:38 $

% Register class (subclass)
pkg = findpackage('resppack');
superclass = findclass(findpackage('wrfc'),'datasource');
c = schema.class(pkg, 'respsource', superclass);
