classdef CovMenus < handle
methods (Static = true)
    schema = settingsMenu(callbackInfo)
    schema = contextMenu(callbackInfo)
end
end