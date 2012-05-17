function schema
% SCHEMA  Defines properties for @timeimportdialog class
%
% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/11/09 16:22:18 $

% Register class 
c = schema.class(findpackage('lsimgui'), 'timeimportdialog');

% Properties

% Structure of java handles describing import data GUI frame
schema.prop(c, 'Importhandles', 'MATLAB array');
% workspace @varbrowser
schema.prop(c, 'Workbrowser', 'handle');
schema.prop(c, 'Frame','com.mathworks.mwswing.MJFrame');
% Private attributes
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off');


