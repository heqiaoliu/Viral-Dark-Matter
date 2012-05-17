function schema
% SCHEMA  Defines properties for @customnetunitfcndialog class

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/05/19 23:04:46 $

% Register class 
c = schema.class(findpackage('nlutilspack'), 'customnetunitfcndialog');

% Properties

% Strucure of java handles describing import data GUI frame
schema.prop(c, 'Handles', 'MATLAB array');

schema.prop(c, 'Frame','com.mathworks.mwswing.MJDialog');

% path and file name info
schema.prop(c,'LastPath','string');
schema.prop(c,'FileNameWithPath','string');
schema.prop(c,'FcnHandle','string');
p = schema.prop(c,'SelectedRadio','MATLAB array');
p.FactoryValue = 1;

schema.prop(c,'CallbackFcn','MATLAB array'); 

% Private attributes
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off');
