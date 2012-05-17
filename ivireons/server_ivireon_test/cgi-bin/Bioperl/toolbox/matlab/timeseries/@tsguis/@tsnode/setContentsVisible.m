function setContentsVisible(h,manager,onoff,varargin)

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2.2.1 $  $Date: 2010/06/21 18:00:24 $

% Overloaded to control the visibility of the PNLEventTable which is 
% controlled by the status of the "Show event table" chackbox as well
% as the visibility of the parent panel

[manager.Panel,manager.HelpPanel] = getDialogInterface(h,manager);
% We are adding this to prevent a painting issue which was found when a
% javacomponent fix was checked in (g482174)
drawnow expose
set(manager.Panel,'Visible',onoff);
% set(setdiff(findobj(manager.Panel,'type','hgjavacomponent'),...
%     h.Handles.PNLeventTable),'Visible',onoff);

%% Events checkbox callback which shown the event pane
if get(h.Handles.CHKevents,'Value')
    set(h.Handles.PNLevents,'Visible',onoff);
    %set(h.Handles.PNLeventTable,'Visible',onoff);
else
    set(h.Handles.PNLevents,'Visible','off');
    %set(h.Handles.PNLeventTable,'Visible','off');
end

set(findobj(manager.Panel,'type','uitabgroup'),'Visible',onoff);
if strcmpi(onoff,'on')
    set(manager.HelpPanel,'Visible',manager.HelpShowing);
    set(manager.Margin(2),'Visible',manager.HelpShowing);
    resizefcn = get(manager.Panel,'ResizeFcn');
    if ~isempty(resizefcn)
        feval(resizefcn{1},manager.Panel,[],resizefcn{2:end});
    end
    drawnow expose; 
    drawnow expose;
end