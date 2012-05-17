function setContentsVisible(h,manager,onoff,varargin)
%Overloaded @node method for managin the visibility of simulinkTsNode
%panels. Called by TreeManager/addCallbacks.
%
%h: handle to the node.
%onoff: should be 'on' or 'off'. 
%manager: handle to the tree manager.

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2.30.1 $  $Date: 2010/06/21 18:00:20 $


[manager.Panel,manager.HelpPanel] = getDialogInterface(h,manager);
if isempty(h) || isempty(h.Handles)
    return
end
set(manager.Panel,'Visible',onoff);
%set(findobj(manager.Panel,'type','hgjavacomponent'),'Visible',onoff);
set(h.Handles.uTabGroup,'vis',onoff);
if isfield(h.Handles,'PNLdata') % Lazy loading may mean that this panel is not there
    set(h.Handles.PNLdata,'vis',onoff);
    if strcmp(get(h.Handles.utabData,'vis'),'off')
        set(h.Handles.TablePanel,'Visible','off');
        %set(h.Handles.PNLeventTable,'Visible','off');
    else
        %set(h.Handles.PNLtstable,'vis','on');
        set(h.Handles.TablePanel,'vis','on');
%         if get(h.Handles.CHKevents,'Value')>0.5
%             set(h.Handles.PNLeventTable,'Visible','on');
%         else
%             set(h.Handles.PNLeventTable,'Visible','off');
%         end
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

