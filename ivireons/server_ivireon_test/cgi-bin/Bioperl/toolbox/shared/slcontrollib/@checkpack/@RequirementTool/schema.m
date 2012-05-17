function schema
%SCHEMA Define the Requirement viewer extension

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:50:47 $

pk = findpackage('checkpack');
c  = schema.class(pk, 'RequirementTool', ...
   findclass(findpackage('uiscopes'), 'AbstractTool'));

%Tool properties
p = schema.prop(c, 'hNewDlg', 'mxArray');       %Handle to new requirement dialog
p.FactoryValue = [];
p = schema.prop(c, 'hEditDlg', 'mxArray');      %Handle to edit requirement dialog
p.FactoryValue = [];
p = schema.prop(c, 'isLocked', 'bool');         %Can requirements be edited
p.FactoryValue = false;
p = schema.prop(c,'isDirty','bool');            %Have the requirements changed
p.FactoryValue = false;
p = schema.prop(c, 'hContextMenus', 'mxArray'); %Handle to context menus added to visualisation
p.FactoryValue = [];
p = schema.prop(c, 'hReq', 'mxArray');          %Handle to graphical requirements
p.FactoryValue = [];
p = schema.prop(c, 'Listeners', 'mxArray');
p.FactoryValue = [];
p = schema.prop(c, 'PreventVisUpdate', 'bool'); %Flag to prevent automatic visualization updates
p.FactoryValue = false;
end