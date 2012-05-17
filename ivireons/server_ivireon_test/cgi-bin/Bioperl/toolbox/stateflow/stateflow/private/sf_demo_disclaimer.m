function sf_demo_disclaimer(cmd)
% SF_DEMO_DISCLAIMER
%	produces an error dialog with an appropriate 
%   Stateflow Demonstration Version disclaimer message.
%

%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.5 $  $Date: 2008/12/01 08:07:13 $
    persistent dialogHandle;
    
    if ~isempty(dialogHandle)
        if ishandle(dialogHandle)
            close(dialogHandle);
        end
        dialogHandle = [];
    end
    
    if nargin > 0
        switch cmd
        case 'close',
            return;
        end
    end

    if(exist(fullfile(matlabroot,'toolbox','stateflow','stateflow','Contents.m'),'file'))
        dialogHandle = errordlg(...
            ['Maximum number of users reached for Stateflow.',10,...
             'Defaulting to a demonstration version of Stateflow.',10 ...
            ,'You can LOAD and SIMULATE Stateflow DEMO diagrams only. Saving',10 ...
            ,'Simulink models containing Stateflow blocks is prohibited.'], 'Unsupported operation for Stateflow Demo License.' ...
        );
    else
        dialogHandle = errordlg(...
            ['Stateflow license could not be checked out.',10,...
             'Defaulting to a demonstration version of Stateflow.',10 ...
            ,'You can LOAD and SIMULATE Stateflow DEMO diagrams only. Saving',10 ...
            ,'Simulink models containing Stateflow blocks is prohibited.'], 'Unsupported operation for Stateflow Demo License.' ...
        );
    end