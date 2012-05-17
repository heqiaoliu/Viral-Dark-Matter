function schema = sl_action_schema
% SL_ACTION_SCHEMA Creates a menu item schema.
%
% A menu item schema specifies the name, callback, and other 
% attributes of a menu item. 
%
% Example:
%    schema = sl_action_schema;
%
% For more information, see <a href="matlab: helpview([docroot '/mapfiles/simulink.map'], 'customize_gui')">Customizing the Simulink User Interface</a>.
%
% See also SL_TOGGLE_SCHEMA, SL_CONTAINER_SCHEMA, 
% SL_REFRESH_CUSTOMIZATIONS, SL_CUSTOMIZATION_MANAGER.


% Copyright 1990-2005 The MathWorks, Inc.
    schema = DAStudio.ActionSchema;
end
