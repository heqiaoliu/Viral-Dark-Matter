function menubar = getMenuBar(this, resources)
% GETMENUBAR Creates the menubar from the given RESOURCES.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2008/12/04 23:19:18 $

menubar = javaObjectEDT('com.mathworks.toolbox.control.explorer.MenuBar', ...
                     resources, this.Explorer );
