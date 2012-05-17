function pcgd_runTestHarn(index,stage)

%   Copyright 2007 The MathWorks, Inc.

    if (nargin == 0)
        index = 1;
        stage = 1;
    end
    % get the base data
    pcgDemoData = evalin('base','pcgDemoData');
    
    % Make sure you are in the correct directory;
     eval(['cd ','''',pcgDemoData.rootDir,'''']);
    % The Model Referane will not run if the model has unsaved changes.
    try
        save_system(pcgDemoData.Models{stage},...
                   [pcgDemoData.rootDir, filesep, pcgDemoData.Models{stage}]);
    catch e % ignore error after saving
        % must have been closed
    end
    
    % run the test harness
    sim(pcgDemoData.Harness{index});
    pcgDemoData.res = logsout;
    RTWDemos.pcgd_plotHarnessData(logsout);
    tmph = msgbox(['Test harness run complete for ',pcgDemoData.Models{stage}]);
    pause(1);
    try
        delete(tmph);    
    catch
        % Must have been deleted by hand
    end
    
    % End: Set the base data
    assignin('base','pcgDemoData',pcgDemoData);
    assignin('base','logsout',logsout);    
end
