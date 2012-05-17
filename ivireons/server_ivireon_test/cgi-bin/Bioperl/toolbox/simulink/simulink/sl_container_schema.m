function schema = sl_container_schema
% SL_CONTAINER_SCHEMA Creates a schema for a submenu.
%
% Example:
%    schema = sl_container_schema;
%
% For more information, see <a href="matlab: helpview([docroot '/mapfiles/simulink.map'], 'customize_gui')">Customizing the Simulink User Interface</a>.
%
% See also SL_ACTION_SCHEMA, SL_TOGGLE_SCHEMA, 
% SL_REFRESH_CUSTOMIZATIONS, SL_CUSTOMIZATION_MANAGER.


% Copyright 1990-2005 The MathWorks, Inc.
    schema = DAStudio.ContainerSchema;
end
