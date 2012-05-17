function [pcgDemoData] = pcgd_modelIsOpen(pcgDemoData,stage,isTestHarn)
    % This function checks to see if the model is open.

%   Copyright 2007 The MathWorks, Inc.

    if (nargin == 2)
        isTestHarn = 0;
    end
    % This function verifies that the model is open
    systems = find_system('type','block_diagram');
    if (isTestHarn == 0)
        index = strcmp(systems,['rtwdemo_PCG_Eval_P',num2str(stage)]);
        if (any(index) == 0)
            % model not open
            [pcgDemoData] = RTWDemos.pcgd_open_pcg_model(stage,0);
        end
    else
        index = strcmp(systems,pcgDemoData.Harness{1});
        if (any(index) == 0)
            % model not open
            [pcgDemoData] = RTWDemos.pcgd_open_pcg_model(stage,1);
        end
        
    end
    
end
