function schema
% SCHEMA  Defines properties for @matpanel class
%
% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:13 $

% Register class 
c = schema.class(findpackage('sharedlsimgui'), 'matpanel');

% Properties

schema.prop(c, 'Panel','MATLAB array');
schema.prop(c, 'matbrowser','handle');
schema.prop(c, 'Jhandles','MATLAB array');
schema.prop(c, 'FilterHandles','MATLAB array');
schema.prop(c, 'Folder','string');