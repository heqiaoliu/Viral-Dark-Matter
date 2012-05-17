function sldemo_mdladv_helper(varargin)
% SLDEMO_MDLADV_HELPER is a helper function for 
% Simulink demo sldemo_mdladv.


%	Copyright 1990-2008 The MathWorks, Inc.
%	$Revision: 1.1.6.7 $  $Date: 2008/12/01 07:49:30 $

persistent buttonClicked

model = 'sldemo_mdladv';
mdladvObj = Simulink.ModelAdvisor.getModelAdvisor(model,'new');
switch (varargin{1})
    case 'selectCheckAll'
        buttonClicked = 'selectCheckAll';
                
        mdladvObj.selectCheckAll;
        mdladvObj.runCheck;        
        mdladvObj.displayReport([mdladvObj.getWorkDir, filesep, 'report.html']);
        
    case 'selectTaskAll'
        buttonClicked = 'selectTaskAll';
        
        mdladvObj.selectTaskAll;
        mdladvObj.runTask;
        mdladvObj.displayReport([mdladvObj.getWorkDir, filesep, 'report.html']);
        
    case 'ShowCheckPassFail'                
        if isempty(buttonClicked)
            errordlg('Please run Model Advisor first.');
            return            
        end
        if strcmp(buttonClicked,'selectCheckAll')
            selectedCheck = mdladvObj.getSelectedCheck;
        else
            selectedCheck = mdladvObj.getSelectedCheckForTask;
        end
        messageToShow = '';
        cr=sprintf('\n');
        for i=1:length(selectedCheck)
            if mdladvObj.getCheckResultStatus(selectedCheck{i})
                messageToShow = [messageToShow cr 'Check: ' selectedCheck{i} ' Pass']; %#ok<AGROW>
            else
                messageToShow = [messageToShow cr 'Check: ' selectedCheck{i} ' Fail']; %#ok<AGROW>
            end
        end
        msgbox(messageToShow,'Check running status');
        
    otherwise
        errordlg('Unknown methods.');
end
