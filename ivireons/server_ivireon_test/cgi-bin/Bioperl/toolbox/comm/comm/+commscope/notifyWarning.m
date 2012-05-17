function notifyWarning(hFig, me)
%NOTIFYWARNING Notify the warning event to the main GUI
%   NOTIFYWARNING(HFIG, ME) finds the main GUI handle in the main GUI figure
%   HGUI by getting the application data of the figure. Then, it calls the
%   warning method of the main GUI with MException ME. 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/31 23:14:43 $

hGui = getappdata(hFig, 'GuiObject');
warning(hGui, me);

%-------------------------------------------------------------------------------
%[EOF]