function schema

% SCHEMA  Defines properties for @varbrowser class

% Author(s): J. G. owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:41 $

% Register class 
c = schema.class(findpackage('sharedlsimgui'), 'varbrowser');

pkg.JavaPackage  =  'com.mathworks.toolbox.control.spreadsheet';
c.JavaInterfaces = {'com.mathworks.toolbox.control.spreadsheet.varbrowserObject'};

% Properties
   
% Path and file name. Empty will be inerpreted as workspace
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

if isempty(javachk('jvm'))
  m = schema.method(c, 'javasend');
  s = m.Signature;
  s.varargin    = 'off';
  s.InputTypes  = {'handle','string','string'};
  s.OutputTypes = {}; 
end