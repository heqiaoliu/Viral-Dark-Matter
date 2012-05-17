function schema
%SCHEMA  Defines properties for @InspectorRoot class

%  Author(s): John Glass
%  Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2007/02/06 20:02:35 $

% Find parent package
pkg = findpackage('explorer');

% Find parent class (superclass)
supclass = findclass(pkg, 'tasknode');

% Register class (subclass) in package
inpkg = findpackage('GenericLinearizationNodes');
c = schema.class(inpkg, 'InspectorRoot', supclass);