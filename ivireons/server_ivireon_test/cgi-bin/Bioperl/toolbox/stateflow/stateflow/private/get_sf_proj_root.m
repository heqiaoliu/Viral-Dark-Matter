function [rootDir,isCustomRootDir] = get_sf_proj_root(startDir) 

%   Copyright 2009-2010 The MathWorks, Inc.

if (slfeature('RTWBuildDirControl') == 0)
    rootDir = startDir; 
    isCustomRootDir = false;
    return;
else
    fileGenCfg = Simulink.fileGenControl('getConfig');
    rootDir    = fileGenCfg.CacheFolder;
    isCustomRootDir = true;
end
    
