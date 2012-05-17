function toolbar = getToolBar(this, resources)
% GETTOOLBAR Creates the toolbar from the given RESOURCES.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2008/12/04 23:19:19 $

toolbar = javaObjectEDT('com.mathworks.toolbox.control.explorer.ToolBar', ...
                     resources, this.Explorer );
