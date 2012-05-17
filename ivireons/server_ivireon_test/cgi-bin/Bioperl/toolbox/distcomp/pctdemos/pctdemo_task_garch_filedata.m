function pctdemo_task_garch_filedata(spec, nSamples, nPaths, networkDir, fileName, eFit, sFit) 
%PCTDEMO_TASK_GARCH_FILEDATA A vectorizing wrapper function around garchsim.
%   The function restricts the amount of data that we get from garchsim to the
%   bare minimum.  This reduction has a significant effect when the return data 
%   is large and it is transmitted over the network.
%   The data is returned by using the file system.
%   
%   This function only returns the cumulative returns.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:52 $
    
    if (nargin < 7)
        returns = pctdemo_task_garch(spec, nSamples, nPaths); %#ok Tell mlint we save returns to file.
    else    
        returns = pctdemo_task_garch(spec, nSamples, nPaths, eFit, sFit); %#ok Tell mlint we save returns to file.
    end
    fullFileName = pctdemo_helper_fullfile(networkDir, fileName);
    % We refuse to overwrite an already existing file.
    if exist(fullFileName, 'file')
        error('distcomp:demo:FileAlreadyExists', ...
              'The file %s already exists', fullFileName);
    end
    save(fullFileName, 'returns');
    
end % End of pctdemo_task_garch_filedata.
