function schema
% SCHEMA  Class definition for subclass of EVENTDATA to handle property names
%         and old/new event data.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:55:05 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('handle');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'EventData');
hCreateInPackage   = findpackage('nlutilspack');

% Construct class
c = schema.class(hCreateInPackage, 'idguievent', hDeriveFromClass);

% Add new enumeration type
if isempty( findtype('idgui_event_types') )
  schema.EnumType( 'idgui_event_types', {'eDataChanged','vDataChanged',...
      'nlarxAdded','nlarxRemoved','nlarxRenamed','nlarxActivated','nlarxDeactivated',...
      'nlhwAdded','nlhwRemoved','nlhwRenamed','nlhwActivated','nlhwDeactivated',...
      'optimStartInfo','optimIterInfo','optimEndInfo',...
      'nlarxColorChanged','nlhwColorChanged'} );
end

% Define properties
p = schema.prop(c, 'propertyName', 'idgui_event_types');   % Name of property that changed

% model added/activated/deactivated/removed and optim related events:
schema.prop(c, 'Info', 'MATLAB array'); 

% renamed/changed (used for any rename and data change in GUI) 
p = schema.prop(c, 'OldValue', 'MATLAB array'); % Old value of the property
p = schema.prop(c, 'NewValue', 'MATLAB array'); % New  value of the property
