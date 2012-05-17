function schema
% SCHEMA  Defines properties for @initialtable class

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2008/09/15 20:36:27 $

% Register class (subclass)
superclass = findclass(findpackage('sharedlsimgui'), 'table');
c = schema.class(findpackage('lsimgui'), 'initialtable', superclass);

% Properties
schema.prop(c, 'importSelector','handle'); 
schema.prop(c, 'numstates','double'); 
schema.prop(c, 'Response','handle'); 