%LISTENERMANAGER Create listener manager.
%   H = LISTENERMANAGER(MODULAR_TOOL,REFRESH_FCN) creates a listener
%   manager associated with MODULAR_TOOL that regulates the firing of the
%   REFRESH_FCN of the tool.
%
%   methods
%   =======
%   installManager(h_tool) installs the listener manager into the appdata
%                          of h_tool
%   refreshTool()          calls the refresh function of the modular tool
%   enableListeners()      enables all listeners created using
%                          reactToImageChangesInFig
%   disableListeners()     disables all listeners created using
%                          reactToImageChangesInFig
%
%   See also IMOVERVIEW.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2010/05/13 17:36:52 $

classdef listenerManager < handle

    properties (SetAccess = 'private', GetAccess = 'private')

        modular_tool
        refresh_fcn

    end % properties

    methods

        function obj = listenerManager(modularTool,refreshFcn)
            %listenerManager  Constructor for listenerManager.
            obj.modular_tool = modularTool;
            obj.refresh_fcn = refreshFcn;
        end

        function installManager(obj,modularTool)
            %installManager  Installs listenerManager into tool appdata.
            setappdata(modularTool,'listenerManager',obj);
        end

        function refreshTool(obj)
            %refreshTool  Refresh modular tool.
            obj.refresh_fcn();
        end

        function enableListeners(obj)
            %enableListeners  Enables react listeners in tool.
            toggleReactListeners(obj.modular_tool,true);
        end

        function disableListeners(obj)
            %disableListeners  Disables react listeners in tool.
            toggleReactListeners(obj.modular_tool,false);
        end

    end % methods
end % classdef


function toggleReactListeners(modular_tool,enable_state)
%toggleReactListeners enables or disables listeners in a modular tool.
%   toggleReactListeners(MODULAR_TOOL,ENABLE_STATE) enables or disables all
%   listeners associated with MODULAR_TOOL that were created using
%   reactToImageChangesInFig.  Valid values for ENABLE_STATE are 'on' and
%   'off'.

if ishghandle(modular_tool)
    
    listener_list = getappdata(modular_tool,'imageChangeListeners');
    
    if ~isempty(listener_list)
        
        listeners = listener_list.getList();

        for i = 1:numel(listeners)

            listener_list.removeItem(listeners(i).ID);
            listeners(i).Item.Enabled = enable_state;
            listener_list.appendItem(listeners(i).Item);

        end
        setappdata(modular_tool,'imageChangeListeners',listener_list);
        
    end
end

end
