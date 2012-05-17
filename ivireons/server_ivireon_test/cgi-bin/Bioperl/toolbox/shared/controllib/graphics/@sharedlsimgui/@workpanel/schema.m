function schema
% SCHEMA  Defines properties for @workpanel class
%
% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:45 $

% Register class 
c = schema.class(findpackage('sharedlsimgui'), 'workpanel');

% Properties

schema.prop(c, 'Panel','MATLAB array');
schema.prop(c, 'workbrowser','handle');
schema.prop(c, 'Jhandles','MATLAB array');
schema.prop(c, 'FilterHandles','MATLAB array');