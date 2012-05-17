function [eDiag,pcgDemoData,rootObj,rootChild] = pcgd_getExplorDialogs(pcgDemoData,stage)
%
%   eDiag == 1 == solver optiosn
%   eDiag == 2 == I/O
%   eDiag == 3 == Optimizations
%   eDiag == 4 == Diagnostiics
%   eDiag == 5 == Hardware implimentation
%   eDiag == 6 == Model Referance
%   eDiag == 7 == RTW 
%   eDiag == 8 == html code
%   eDiag == 9 == workspace data

%   Copyright 2007 The MathWorks, Inc.

    % 0.) get base workspace information
    eDiag   = {};
    try
        rootObj = pcgDemoData.explrDiag.getRoot;
    catch
        % explr object dosn't exist: create it
        pcgDemoData.explrDiag = daexplr;
        rootObj               = pcgDemoData.explrDiag.getRoot;
        % Save off the data
        assignin('base','pcgDemoData',pcgDemoData);
    end
    pcgDemoData.explrDiag.show;
    curModel     = ['rtwdemo_PCG_Eval_P',num2str(stage)];
    
    temp         = rootObj.find('-isa','Simulink.SolverCC'); % 1 solver 
    for inx = 1 : length(temp)
       parName{inx}      = get_param(temp(inx).getParent.getModel,'Name');   
    end
    index        = find(strcmp(parName,curModel)==1);
    eDiag{1}     = temp(index);
    
    temp         = rootObj.find('-isa','Simulink.DataIOCC'); % 2 I/O
    clear parName;    
    for inx = 1 : length(temp)
       parName{inx}      = get_param(temp(inx).getParent.getModel,'Name');   
    end
    index        = find(strcmp(parName,curModel)==1);
    eDiag{end+1} = temp(index);
    
    temp         =  rootObj.find('-isa','Simulink.OptimizationCC'); % 3 Optimizations
    clear parName;
    for inx = 1 : length(temp)
       parName{inx}      = get_param(temp(inx).getParent.getModel,'Name');   
    end
    index        = find(strcmp(parName,curModel)==1);
    eDiag{end+1} = temp(index);

    temp         = rootObj.find('-isa','Simulink.DebuggingCC'); % 4 Diagnostitics
    clear parName;    
    for inx = 1 : length(temp)
       parName{inx}      = get_param(temp(inx).getParent.getModel,'Name');   
    end
    index        = find(strcmp(parName,curModel)==1);
    eDiag{end+1} = temp(index);

    temp         = rootObj.find('-isa','Simulink.HardwareCC'); % 5 Hardware
    clear parName;    
    for inx = 1 : length(temp)
       parName{inx}      = get_param(temp(inx).getParent.getModel,'Name');   
    end
    index        = find(strcmp(parName,curModel)==1);
    eDiag{end+1} = temp(index);
    
    temp         = rootObj.find('-isa','Simulink.ModelReferenceCC'); % 6 Model Referance
    clear parName;    
    for inx = 1 : length(temp)
       parName{inx}      = get_param(temp(inx).getParent.getModel,'Name');   
    end
    index        = find(strcmp(parName,curModel)==1);
    eDiag{end+1} = temp(index);

    temp         = rootObj.find('-isa','Simulink.RTWCC'); % 7 RTW
    clear parName;    
    for inx = 1 : length(temp)
       parName{inx}      = get_param(temp(inx).getParent.getModel,'Name');   
    end
    index        = find(strcmp(parName,curModel)==1);
    eDiag{end+1} = temp(index);
    
    temp         = rootObj.find('-isa','Simulink.code'); % 8 html code
    clear parName;
    for inx = 1 : length(temp)
       parName{inx}      = temp(inx).getParent.getFullName;
    end
    index        = find(strcmp(parName,curModel)==1);
    eDiag{end+1} = temp(index);
    
    % simulink root object : 
    % 1 == base workspace
    % 2 == Configuration Preferences
    % 3 == the model (simulink block diagram)
    
    rootChild    = rootObj.getChildren;
    eDiag{end+1} = rootChild(1); % base workspace
    
end 
  
