function huiRFL = connect(huiRFL)
%CONNECT Adaptor method to invoke ConnectMenu on RecentFilesList object.

% Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2010/03/31 18:43:30 $

% Get handle to underlying RecentFilesList object
% and invoke ConnectMenu method
connectMenu(huiRFL.recentFiles,huiRFL.GraphicalParent);

% render() method expects a return handle
% delete() is called on this to close it up
%
% We pass back the uirecentfileslist object,
% which has the appropriate delete() method

% Add a listener to the parent menu, so if it gets destroyed,
% we can clear the .hWidget handle of the uirecentitemslist object.
% We do that to signify that we are no longer attached to the menu
% system, and a subsequent render() operation will attempt to
% re-connect the uirecentitemslist to the menu.
%
% Without this, we cannot re-render properly after a "gui closed"
% event.  It's not that common to re-use the hierarchy in this way,
% but this is clean.  It costs a bit of time whenever a recentitemslist
% is used, in order to build the listener.
%
% G615434: In HG2, handle.listener will error out. So changing this to
% uiservices.addlistener instead which takes care of both HG1 and HG2 modes
% (G615382).
hListen = uiservices.addlistener(...
    huiRFL.GraphicalParent, 'ObjectBeingDestroyed', @(hh,ev)uiRFL_destroy(huiRFL));

% Hold listener to parent menu object while we're connected to it
%
% No need to manage/delete this, since it goes out of scope
% whenever the parent menu is destroyed.
%
setappdata(huiRFL.GraphicalParent,'uimgr_uirecentitemslist_connect', hListen);

% --------------------------------------------
function uiRFL_destroy(huiRFL)
% Clear the hWidget handle, so next render() cycle will cause
% recentFiles object to re-connect to the parent menu:

% Note: handle could be bogus if object cleared
%       before GUI is closed
% input to ishghandle only hghandle
if ishghandle(huiRFL)
	huiRFL.hWidget = [];
end

% [EOF]
