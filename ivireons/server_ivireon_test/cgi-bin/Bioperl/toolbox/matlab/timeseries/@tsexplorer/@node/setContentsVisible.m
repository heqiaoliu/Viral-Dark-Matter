function setContentsVisible(h,manager,onoff,varargin)
%Root method which should be overloaded by specialized nodes for managing
%the visibility of their panels. Called by TreeManager/addCallbacks.
%
%h: handle to the node.
%onoff: should be 'on' or 'off'. 
%manager: handle to the tree manager.

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:33:39 $

[manager.Panel,manager.HelpPanel] = getDialogInterface(h,manager);
set(manager.Panel,'Visible',onoff);
set(findobj(manager.Panel,'type','uitabgroup'),'Visible',onoff);
if strcmpi(onoff,'on')
    set(manager.HelpPanel,'Visible',manager.HelpShowing);
    set(manager.Margin(2),'Visible',manager.HelpShowing);
    resizefcn = get(manager.Panel,'ResizeFcn');
    if ~isempty(resizefcn)
        feval(resizefcn{1},manager.Panel,[],resizefcn{2:end});
    else
        %get(manager.Panel)
    end
    drawnow expose; 
    drawnow expose;
end