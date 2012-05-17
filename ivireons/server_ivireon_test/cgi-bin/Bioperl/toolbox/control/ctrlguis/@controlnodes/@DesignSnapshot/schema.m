function schema
%  SCHEMA  Defines properties for TunedBlockSnapshot class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 00:45:39 $

% Find parent package
pkg = findpackage('explorer');

% Find parent class (superclass)
supclass = findclass(pkg, 'node');

% Register class (subclass) in package
inpkg = findpackage('controlnodes');
c = schema.class(inpkg, 'DesignSnapshot', supclass);

% Properties
schema.prop(c, 'TunedBlocks', 'MATLAB array');
p.FactoryValue = true;