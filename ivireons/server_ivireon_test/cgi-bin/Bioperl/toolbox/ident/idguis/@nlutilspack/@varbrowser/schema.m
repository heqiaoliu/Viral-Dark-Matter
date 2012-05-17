function schema
% SCHEMA  Defines properties for @varbrowser class

% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/06/07 14:42:21 $

% Register class 
c = schema.class(findpackage('nlutilspack'), 'varbrowser');

pkg.JavaPackage  =  'com.mathworks.toolbox.control.spreadsheet';
c.JavaInterfaces = {'com.mathworks.toolbox.control.spreadsheet.varbrowserObject'};

% Properties
   
% Path and file name. Empty will be interpreted as workspace
schema.prop(c, 'filename','string');
% Structure array containing displayed information on variables
schema.prop(c, 'variables','MATLAB array');
% Cell array to filter the data types to be displayed (empty => no filter)
schema.prop(c, 'typesallowed','MATLAB array');
% ImportView Java handle
% schema.prop(c, 'javahandle','com.mathworks.toolbox.control.spreadsheet.ImportView');
schema.prop(c, 'javahandle','MATLAB array');
% Private attributes
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'on', 'AccessFlags.PublicSet', 'on');
% events
schema.event(c,'rightmenuselect'); 
schema.event(c,'listselect'); 

if isempty( findtype('IdImportSource') )
  schema.EnumType( 'IdImportSource', {'workspace','file'});
end

schema.prop(c, 'ImportSource', 'IdImportSource');

if isempty(javachk('jvm'))
  m = schema.method(c, 'javasend');
  s = m.Signature;
  s.varargin    = 'off';
  s.InputTypes  = {'handle','string','string'};
  s.OutputTypes = {}; 
end
