function setContentsVisible(h,manager,onoff,varargin)
%Overloaded @node method for managin the visibility of simulinkTsarrayNode
%panels. Called by TreeManager/addCallbacks.
%
%h: handle to the node.
%onoff: should be 'on' or 'off'. 
%manager: handle to the tree manager.

%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/27 22:43:10 $


[manager.Panel,manager.HelpPanel] = getDialogInterface(h,manager);
if isempty(h) || isempty(h.Handles)
    return
end
set(manager.Panel,'Visible',onoff);
%set(findobj(manager.Panel,'type','hgjavacomponent'),'Visible',onoff);
set(h.Handles.PNLTsOuter,'vis',onoff);
set(h.Handles.uTabGroup,'vis',onoff);
if isfield(h.Handles,'PNLModelTables') % Panel may not exist due to lazy loading
    if strcmp(get(h.Handles.utabRegular,'vis'),'off')
        set(h.Handles.PNLModelTables,'vis','off');
    else
        set(h.Handles.PNLModelTables,'vis','on');
    end
end
if strcmpi(onoff,'on')
    resizefcn = get(manager.Panel,'ResizeFcn');
    if ~isempty(resizefcn)
        feval(resizefcn{1},manager.Panel,[],resizefcn{2:end});
    else
        %get(manager.Panel)
    end
    set(manager.HelpPanel,'Visible',manager.HelpShowing);
    set(manager.Margin(2),'Visible',manager.HelpShowing);
    drawnow expose;
    drawnow expose;
end
