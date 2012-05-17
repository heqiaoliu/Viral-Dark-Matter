function pcgd_buildDemo(modelNum,mode,subSys)
    % Note: subSys is only used for mode 2
    % 0.) get base data

%   Copyright 2007 The MathWorks, Inc.

    [pcgDemoData] = RTWDemos.pcgd_startEmbeddedCoderOverview;
    
    % Make sure the model is open
    [pcgDemoData] = RTWDemos.pcgd_modelIsOpen(pcgDemoData,modelNum,0);
    
    % Make sure you are in the correct directory:
    eval(['cd ','''',pcgDemoData.rootDir,'''']);
    
    if (mode ~= 4)
        if (modelNum == 6)
            RTWDemos.pcgd_configForSFun(modelNum,2); % code and exe (for zip)
        else
            RTWDemos.pcgd_configForSFun(modelNum,3); % code only
        end
    else % s-function to be generated for the full model
        RTWDemos.pcgd_configForSFun(modelNum,1);                    
    end
    % set default to fail   
    passed      = 0;
    % 1.) build...
    if (mode == 0) % full system build
        try
            rtwbuild(pcgDemoData.Models{modelNum});
            passed = 1;
        catch
        end
    elseif (mode == 1) % build by subsystem
        numSubs = length(pcgDemoData.atomicSubs);
        for inx = 1 : numSubs
            try
                rtwbuild(pcgDemoData.atomicsSubs{inx});
                passed = 1;
            catch
                
            end
        end
    elseif (mode == 2)
        try
            rtwbuild([pcgDemoData.Models{modelNum},'/',subSys],...
                     'Mode','ExportFunctionCalls');
            passed = 1;
        catch
        end
    elseif (mode == 3)
        % Build subsystem for one subsystem
        try
            rtwbuild([pcgDemoData.Models{modelNum},'/',subSys]);
            passed = 1;
        catch
        end
    elseif (mode == 4)
        %% generate a s-function wrapper for the model: save the s-function
        %% after generation
        try
            rtwbuild(pcgDemoData.Models{modelNum});
        catch
        end
    end
    
    if (passed == 1)
       tmph = msgbox(['Build completed for ',pcgDemoData.Models{modelNum}]);
       pause(1);
       try
           delete(tmph);    
       catch
           % Someone may have already deleted the box...
       end
    end
end
