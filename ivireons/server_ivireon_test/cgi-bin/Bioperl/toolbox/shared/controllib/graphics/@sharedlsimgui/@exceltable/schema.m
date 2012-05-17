function schema
% SCHEMA  Defines properties for @exceltable class

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:00 $

% Find parent package
% Register class (subclass)
superclass = findclass(findpackage('sharedlsimgui'), 'table');
c = schema.class(findpackage('sharedlsimgui'), 'exceltable', superclass);

% Properties
schema.prop(c, 'filename','MATLAB array');   
schema.prop(c, 'sheetname','MATLAB array');   
schema.prop(c, 'numdata','MATLAB array');  