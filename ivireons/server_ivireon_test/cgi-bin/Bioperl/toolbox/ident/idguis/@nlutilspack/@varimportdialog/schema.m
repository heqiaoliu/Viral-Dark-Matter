function schema
% SCHEMA  Defines properties for @varimportdialog class

% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/06/07 14:42:24 $

% Register class 
c = schema.class(findpackage('nlutilspack'), 'varimportdialog');

% Properties

% Strucure of java handles describing import data GUI frame
schema.prop(c, 'Importhandles', 'MATLAB array');
% workspace @varbrowser
schema.prop(c, 'Workbrowser', 'handle');
schema.prop(c, 'Frame','com.mathworks.mwswing.MJDialog');
schema.prop(c,'LastPath','string');

% Private attributes
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off');

