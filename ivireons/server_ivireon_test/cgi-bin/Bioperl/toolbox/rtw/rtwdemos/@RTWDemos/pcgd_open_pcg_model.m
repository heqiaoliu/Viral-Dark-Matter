function [pcgDemoData] = pcgd_open_pcg_model(modNumber,openMode,subSystem)
    % This function opens the PCG Model, which model is open depends on the
    % Input Aguments
    % modNumber = the number of the model
    % openMode  = how to open
    %   == 0 == Open new model
    %   == 1 == Opens the test harness
    %   == 2 == Opens the subsystem
    %   == 3 == Opens a helper function
    %   == 4 == Opens the S-Function test harness

%   Copyright 2007 The MathWorks, Inc.

    % subSystem == the subsystem to be opened 
    % 0.) Get the base data
    [pcgDemoData] = RTWDemos.pcgd_startEmbeddedCoderOverview;
    
    % 1.)
    if (nargin == 2)
        subSystem = '';
    end

    % First check and see if the stateflow window is open
    if (openMode == 0) % opens a new model
        open_system(pcgDemoData.Models{modNumber});
        if (modNumber <= 5) % Tracking the current window...
            pcgDemoData.curWindow = pcgDemoData.Models{modNumber};
        end
    elseif (openMode == 1) % Open the test harness model
        open_system(pcgDemoData.Harness{1});
        set_param([pcgDemoData.Harness{1},'/Unit_Under_Test'],...
                   'ModelName',pcgDemoData.Models{modNumber});
    elseif (openMode == 2)
        % 1.) Verify that the model is open
        [pcgDemoData] = RTWDemos.pcgd_modelIsOpen(pcgDemoData,modNumber);
        pathTo        = [pcgDemoData.Models{modNumber},'/',subSystem];
        if (strcmp(get_param(pathTo,'MaskType'),'Stateflow'))
            open_system(pathTo);
            par                   = get_param(pathTo,'Parent');
            pcgDemoData.curWindow = par;
            try
                open_system(par,pcgDemoData.curWindow,'reuse');
            catch
                open_system(par,pcgDemoData.curWindow);
            end
        else
            try
                if (strcmp(pcgDemoData.curWindow,pathTo))
                    open_system(pathTo);                                    
                else
                    open_system(pathTo,pcgDemoData.curWindow,'reuse');
                end
            catch
                open_system(pathTo);                
                % do nothing in this case: already open
            end
            pcgDemoData.curWindow = [pcgDemoData.Models{modNumber},'/',subSystem];
        end
    elseif (openMode == 3)
        open_system(pcgDemoData.helper{modNumber});
    elseif (openMode == 4)
        % Open the S-Function test harness
        open_system(pcgDemoData.Harness{2});
    end
    
    %
    % Make sure the model is visable
    gco = get_param(gcs,'Object');
    gco.view;
    %
    % End: Set the base data
    %
    assignin('base','pcgDemoData',pcgDemoData);
 
end
