function pcgd_autoSetup(stage)
    % This function will automatically set up the Eclipse directory

%   Copyright 2007 The MathWorks, Inc.
    
    % 0.) Get the pcg information
    pcgDemoData = evalin('base','pcgDemoData');

    % 1.) Create the build dir
    if (stage == 6)
        system(['mkdir ',pcgDemoData.rootDir,'\Eclipse_Build_P6']);
    else
        system(['mkdir ',pcgDemoData.rootDir,'\Eclipse_Build_P5']);
    end
    
    % 2.) Unzip the files into the build dir
    if (stage == 6)
        unzip('rtwdemo_PCG_Eval_P6.zip',[pcgDemoData.rootDir,'\Eclipse_Build_P6']);
    else
        unzip('rtwdemo_PCG_Eval_P5.zip',[pcgDemoData.rootDir,'\Eclipse_Build_P5']);        
    end
    
    % 3.) Delete the files that are not wanted

    if (stage == 6)
        delete(fullfile(pcgDemoData.rootDir,'Eclipse_Build_P6','rtwdemo_PCG_Eval_P6.c'));
        delete(fullfile(pcgDemoData.rootDir,'Eclipse_Build_P6','ert_main.c'));            
    elseif (stage == 5)
        delete(fullfile(pcgDemoData.rootDir,'Eclipse_Build_P5','rtwdemo_PCG_Eval_P5.c'));
        delete(fullfile(pcgDemoData.rootDir,'Eclipse_Build_P5','ert_main.c'));                 
    end

   % Let the users know it is done.
   tmph = msgbox('The build directory is set up');
   pause(2);
   try
       delete(tmph);    
   catch
       % Must have been manually set up
   end
    
end
