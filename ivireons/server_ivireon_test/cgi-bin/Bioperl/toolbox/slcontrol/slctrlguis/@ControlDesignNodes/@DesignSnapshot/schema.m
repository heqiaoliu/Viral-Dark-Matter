function schema
%  SCHEMA  Defines properties for TunedBlockSnapshot class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 19:08:00 $

% Find parent package
pkg = findpackage('controlnodes');

% Find parent class (superclass)
supclass = findclass(pkg, 'DesignSnapshot');

% Register class (subclass) in package
inpkg = findpackage('ControlDesignNodes');
c = schema.class(inpkg, 'DesignSnapshot', supclass);