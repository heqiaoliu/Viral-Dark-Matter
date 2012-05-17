function schema
% SCHEMA  Defines properties for @csvpanel class
%
% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:50 $

% Register class 
c = schema.class(findpackage('sharedlsimgui'), 'csvpanel');

% Properties

schema.prop(c, 'Panel','MATLAB array');
schema.prop(c, 'csvsheet','handle');
schema.prop(c, 'Jhandles','MATLAB array');
schema.prop(c, 'FilterHandles','MATLAB array');
schema.prop(c, 'Folder','string');