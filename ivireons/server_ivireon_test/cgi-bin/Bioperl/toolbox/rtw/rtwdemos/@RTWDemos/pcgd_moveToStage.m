function pcgd_moveToStage(stage,curStage)
    % get the base data

%   Copyright 2007 The MathWorks, Inc.

    pcgDemoData = evalin('base','pcgDemoData');

    % Make sure you are in the working directory
    eval(['cd ',pcgDemoData.rootDir]);
    
    % Close out the old models: save locally
    if (curStage ~=0)
        % save the system locally
        try
            save_system(pcgDemoData.Models{curStage},...
                       [pcgDemoData.rootDir,'\',pcgDemoData.Models{curStage}]);
        catch
            % must have been closed
        end
        bdclose('all');
    end
            
    % next save a local copy of the data
    evalin('base',['warning off;save PCG_Demo_',num2str(curStage),'_data;warning on;']);    
    
    % Close out all figures and the dow
    hAllChild = allchild(0);
    close(hAllChild);
   
    % 4.) Clear all data from the base workspace
    evalin('base','clear');
    
    % 5.) reset data in the pcgDemoData structure
    pcgDemoData.curWindow     = {};
    pcgDemoData.explDiags     = [];

    % Save off the pcg demo data
    assignin('base','pcgDemoData',pcgDemoData);
    
    % Load the system
    if( (stage ~= 0) && (stage ~= 7))
        [pcgDemoData] = open_pcg_model(stage,0);
    end
    
    % Open the web browser
    
    if (stage == 0)
        [stat, webH] = web('production_code_demo.html',...
                           '-notoolbar',...
                           '-noaddressbox');
    else
        [stat, webH] = web(['stage_',num2str(stage),'_p1.html'],...
                            '-notoolbar',...
                            '-noaddressbox');
    end
    pcgDemoData.webH = webH;
    
    % Save off the pcg demo data
    assignin('base','pcgDemoData',pcgDemoData);
    % Clear up and c and h files that are hanging around in this directory
    if (curStage >= 4)
        system('del *.c');
        system('del *.h');
    end
   
    % Special case: if stage 4 move the simpleTable.h and SimpleTable.c
    % files to the current directory
    if (stage == 4)
        system(['copy ',pcgDemoData.demoLoc,'\stage_4_files\*.* ',...
               pcgDemoData.rootDir,'\.']);
    elseif (stage == 5)
        % Need the "main" files
        system(['copy ',pcgDemoData.demoLoc,'\stage_5_files\*.* .']);
    elseif (stage == 6)
        if (pcgDemoData.is7a == 0) % e.g. it is 6b      
           system(['copy ',pcgDemoData.demoLoc,'\ertsfcnbody.tlc  .']);
        end
        system(['copy ',pcgDemoData.demoLoc,'\stage_6_files\*.* .']);
        load([pcgDemoData.demoLoc,'\logsout_data']);            
        assignin('base','logsout',logsout); %Transfer the data to the base
    end            
end

