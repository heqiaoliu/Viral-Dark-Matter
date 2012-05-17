function schema
% SCHEMA  Defines properties for @asctable class

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:47 $

% Find parent package
% Register class (subclass)
superclass = findclass(findpackage('sharedlsimgui'), 'table');
c = schema.class(findpackage('sharedlsimgui'), 'asctable', superclass);

% Properties

schema.prop(c, 'filename','string');   
schema.prop(c, 'delimiter','string');   
schema.prop(c, 'numdata','MATLAB array');  

