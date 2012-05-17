function schema
% SCHEMA  Defines properties for @ascpanel class
%
% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:44 $

% Register class 
c = schema.class(findpackage('sharedlsimgui'), 'ascpanel');

% Properties

schema.prop(c, 'Panel','MATLAB array');
schema.prop(c, 'ascsheet','handle');
schema.prop(c, 'Jhandles','MATLAB array');
schema.prop(c, 'FilterHandles','MATLAB array');
schema.prop(c, 'Folder','string');