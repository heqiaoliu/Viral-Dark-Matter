function schema
% SCHEMA  Defines properties for @csvtable class

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:53 $

% Find parent package
% Register class (subclass)
superclass = findclass(findpackage('sharedlsimgui'), 'table');
c = schema.class(findpackage('sharedlsimgui'), 'csvtable', superclass);

% Properties
schema.prop(c, 'filename','MATLAB array');   
schema.prop(c, 'numdata','MATLAB array');     

