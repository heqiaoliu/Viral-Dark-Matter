function Menu = findMenu(this,Tag)
%FINDMENU  Finds right-click menu with specified tag.

%  Author(s): James Owen
%  Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $ $Date: 2009/12/22 18:57:42 $
Menu = handle(findobj(this.UIcontextMenu,'Tag',Tag));
