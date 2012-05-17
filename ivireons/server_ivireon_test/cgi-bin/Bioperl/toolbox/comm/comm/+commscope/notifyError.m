function notifyError(hFig, me)
%NOTIFYERROR Notify the error event to the main GUI
%   NOTIFYERROR(HFIG, ME) finds the main GUI handle in the main GUI figure
%   HGUI by getting the application data of the figure. Then, it calls the
%   error method of the main GUI with MException ME. 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/31 23:14:42 $

hGui = getappdata(hFig, 'GuiObject');
error(hGui, me);

%-------------------------------------------------------------------------------
%[EOF]