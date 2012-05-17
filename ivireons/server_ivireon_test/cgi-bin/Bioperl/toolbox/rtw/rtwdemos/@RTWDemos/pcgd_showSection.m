function [fullFile] = pcgd_showSection(modNum,section,path)
    % 0.) Get base data

%   Copyright 2007 The MathWorks, Inc.

    pcgDemoData = evalin('base','pcgDemoData');
    
    % 1.) define the path to the model
    filePath = [pwd,'\',pcgDemoData.Models{modNum},'_ert_rtw\html\'];

    if (nargin == 3)
        fileName = [section,'.html'];
        filePath = [pwd,'\',path,'\html\'];
    elseif (strcmp(section,'func'))
        fileName = [pcgDemoData.Models{modNum},'_c.html'];
    elseif (strcmp(section,'func_data'))
        fileName = [pcgDemoData.Models{modNum},'_data_c.html'];
    elseif (strcmp(section,'ert_main'))
        fileName = 'ert_main_c.html';        
    elseif (strcmp(section,'data_def'))
        fileName = [pcgDemoData.Models{modNum},'_h.html'];        
    elseif (strcmp(section,'private'))
        fileName = [pcgDemoData.Models{modNum},'_private_h.html'];        
    elseif (strcmp(section,'func_types'))
        fileName = [pcgDemoData.Models{modNum},'_types_h.html'];        
    elseif (strcmp(section,'PI')) 
        fileName = [pcgDemoData.Models{modNum},'_PI_ctrl_1_c.html'];
    elseif (strcmp(section,'Stateflow'))
        fileName = 'Pos_Command_Arbitration_c.html';      
    elseif (strcmp(section,'Reusable'))
        fileName = 'PI_Cntrl_Reusable_c.html';
    elseif (strcmp(section,'eval_data_c'))
        fileName = 'eval_data_c.html';
    elseif (strcmp(section,'eval_data_h'))
        fileName = 'eval_data_h.html';
    elseif (strcmp(section,'rtwtypes'))
        fileName = 'rtwtypes_h.html';
    elseif (strcmp(section,'Simple_c'))
        fileName = 'SimpleTable.html';
        filePath =[pcgDemoData.demoLoc,'\'];
    elseif (strcmp(section,'R2006b'))
        fileName = 'R2006B_SFunction_Generation_with_Busses.html';
        filePath =[pcgDemoData.demoLoc,'\'];
    end
    fullFile = [filePath,fileName];
    helpview([filePath,fileName],'CSHelpWindow')        
        
end
