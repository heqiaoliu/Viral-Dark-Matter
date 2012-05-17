function s = loadobj(s)
% LOADOBJ Overloaded load method.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/01/26 01:45:54 $

if strcmp(s.Resources, 'com.mathworks.toolbox.control.resources.Explorer_Menus_Toolbars')
  s.Resources = 'com.mathworks.toolbox.control.resources.SISOTool_Menus_Toolbars';
end
