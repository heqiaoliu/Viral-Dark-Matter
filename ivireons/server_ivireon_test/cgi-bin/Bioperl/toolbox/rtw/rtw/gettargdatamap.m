function targDataMap = gettargdatamap(relBuildDir,name)
% GETTARGDATAMAP calls the generated  MATLAB file model_targ_data_map.m and returns
%  data type transition information about the target.
%


%   Copyright 2001-2010 The MathWorks, Inc.
%   $Revision: 1.2.2.5.2.1 $  $Date: 2010/06/24 19:42:32 $
  
origDir = pwd;

try
    fgCfg = Simulink.fileGenControl('getConfig');
    buildDir = fullfile(fgCfg.CodeGenFolder,relBuildDir);
    cd(buildDir);

    %
    % Force MATLAB to read the file from disk because it may have been changed
    % during RTW build process.  If we do not clear it, we may get a cached
    % version of the file with incorrect information.
    %
    eval(['clear ' name '.m']);
    
    targDataMap = feval(name);        
  
catch ME
    cd(origDir);
    rethrow(ME);
end

cd(origDir);

% LocalWords:  targ
