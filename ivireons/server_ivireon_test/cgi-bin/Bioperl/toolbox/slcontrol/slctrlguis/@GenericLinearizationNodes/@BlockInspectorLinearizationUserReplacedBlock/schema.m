function schema
%SCHEMA  Defines properties for @BlockInspectorLinearization class

%  Author(s): John Glass
%  Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2009/03/31 00:22:57 $

% Register class (subclass) in package
inpkg = findpackage('GenericLinearizationNodes');
c = schema.class(inpkg, 'BlockInspectorLinearizationUserReplacedBlock');

schema.prop(c, 'InLinearizationPath','string');
schema.prop(c, 'SystemData', 'MATLAB array');
schema.prop(c, 'FullBlockName', 'string');
schema.prop(c, 'indu', 'MATLAB array');
schema.prop(c, 'indy', 'MATLAB array');
