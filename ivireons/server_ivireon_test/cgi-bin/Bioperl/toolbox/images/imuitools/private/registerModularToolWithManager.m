function registerModularToolWithManager(modular_tool,target_image)
%registerModularToolWithManager registers a modular tool with the modular tool manager of a target image.
%   registerModularToolWithManager(MODULAR_TOOL,TARGET_IMAGE) registers
%   MODULAR_TOOL with the modular tool manager of TARGET_IMAGE.  If a
%   modular tool manager is not already present then one will be created.
%
%   See also IMOVERVIEW.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/02/07 16:30:45 $

for i = 1:numel(target_image)

    % create a modular tool manager if  necessary
    current_image = target_image(i);
    modular_tool_manager = getappdata(current_image,'modularToolManager');
    if isempty(modular_tool_manager)
        modular_tool_manager = iptui.modularToolManager(current_image,makeList());
    end

    % register the tool with the manager
    modular_tool_manager.registerTool(modular_tool);

    % store manager in image appdata
    setappdata(current_image,'modularToolManager',modular_tool_manager);

end
