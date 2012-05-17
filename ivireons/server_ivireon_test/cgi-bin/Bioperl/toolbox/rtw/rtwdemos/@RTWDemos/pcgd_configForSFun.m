function pcgd_configForSFun(modelNum,setToMode)

%   Copyright 2007 The MathWorks, Inc.
    
    % This function sets the configuration options required to
    % automatically generate an S-function wrapper for the model

    % 0.) get the base data
    pcgDemoData = evalin('base','pcgDemoData');
    
    % 1.) Validate that the model is open
    RTWDemos.pcgd_modelIsOpen(pcgDemoData,modelNum);
    cs = getActiveConfigSet(['rtwdemo_PCG_Eval_P',num2str(modelNum)]);    
    % 2.) Set the config set option to off
    if (setToMode == 1)
        % Generating the S-function wrapper
        cs.set_param('GenCodeOnly','off');
        cs.set_param('GenerateErtSFunction','on');
    elseif (setToMode == 2)
        % Generating code and exe (for zip file)
        cs.set_param('GenCodeOnly','on');
        cs.set_param('GenerateErtSFunction','off');
    elseif (setToMode == 3)
        % Generating code only
        cs.set_param('GenCodeOnly','on');
        cs.set_param('GenerateErtSFunction','off');
    end
        
end

    
