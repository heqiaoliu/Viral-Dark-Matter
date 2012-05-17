%MODULARTOOLMANAGER Create modular tool manager.
%   H = MODULARTOOLMANAGER(TARGET_IMAGE) creates a modular tool manager
%   associated with TARGET_IMAGE to actively manage the refreshing of each
%   modular tool.
%
%   methods
%   =======
%   registerTool(h_tool) registers the tool, h_tool, with the manager.
%   enableTools()        enables all modular tools' listeners created using
%                        reactToImageChangesInFig
%   disableTools()       disables all modular tools' listeners created
%                        using reactToImageChangesInFig
%   refreshTools()       calls all modular tools' refresh functions
%
%   See also IMOVERVIEW.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2008/12/22 23:47:39 $

classdef modularToolManager < handle

    properties (SetAccess = 'private', GetAccess = 'private')

        target_image
        tool_list

    end % properties

    methods

        function obj = modularToolManager(targetImage,tool_list)
            %modularToolManager  Constructor for modularToolManager.
            obj.target_image = targetImage;
            obj.tool_list    = tool_list;
        end

        function registerTool(obj,h_tool)
            %registerTool  Registers a tool with the manager.
            obj.tool_list.appendItem(h_tool);
        end

        function enableTools(obj)
            %enableTools  Enables react listeners in all tools.
            enableModularTools(obj.tool_list,true);
        end

        function disableTools(obj)
            %disableTools  Disables react listeners in all tools.
            enableModularTools(obj.tool_list,false);
        end

        function refreshTools(obj)
            %refreshTools  Refresh all modular tools.

            % get all tools
            modular_tools = obj.tool_list.getList();

            % disable the listeners in each tool
            for i = 1:numel(modular_tools)

                if ishghandle(modular_tools(i).Item)

                    listener_mgr = getappdata(modular_tools(i).Item,'listenerManager');
                    if ~isempty(listener_mgr)
                        listener_mgr.refreshTool();
                    end

                else
                    % remove invalid list items
                    obj.tool_list.removeItem(modular_tools(i).ID);
                end
            end

        end

    end % methods
end % classdef


function enableModularTools(tool_list,tools_enabled)
%enableModularTools enables or disables modular tools.
%   enableModularTools(TARGET_IMAGE,TOOLS_ENABLED) enables or disables all
%   modular tools associated with the TARGET_IMAGE.  Valid values for
%   TOOLS_ENABLED are true and false.

% get all tools
modular_tools = tool_list.getList();

% disable the listeners in each tool
for i = 1:numel(modular_tools)

    if ishghandle(modular_tools(i).Item)

        listener_mgr = getappdata(modular_tools(i).Item,'listenerManager');

        if ~isempty(listener_mgr)
            if tools_enabled
                listener_mgr.enableListeners();
            else
                listener_mgr.disableListeners();
            end
        end

    else
        % remove invalid list items
        tool_list.removeItem(modular_tools(i).ID);
    end
end

end % enableModularTools

