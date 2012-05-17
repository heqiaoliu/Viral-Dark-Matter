function schema = sl_toggle_schema
% SL_TOGGLE_SCHEMA Creates a schema for a toggle menu item.
%
% A toggle menu item is an item that has an on or off state
% indicated by the presence or absence of a checkmark, respectively.
%
% Example:
%    schema = sl_toggle_schema;
%
% For more information, see <a href="matlab: helpview([docroot '/mapfiles/simulink.map'], 'customize_gui')">Customizing the Simulink User Interface</a>.
%
% See also SL_ACTION_SCHEMA, SL_CONTAINER_SCHEMA, 
% SL_REFRESH_CUSTOMIZATIONS, SL_CUSTOMIZATION_MANAGER.



% Copyright 1990-2005 The MathWorks, Inc.
    schema = DAStudio.ToggleSchema;
end
