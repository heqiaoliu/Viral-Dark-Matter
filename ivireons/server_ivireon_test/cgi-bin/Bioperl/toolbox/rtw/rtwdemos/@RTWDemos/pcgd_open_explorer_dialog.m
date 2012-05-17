function pcgd_open_explorer_dialog(model, diagName, tabSel)
% This function opens a given dialog in the model explorer.  The inputs are
% as follows:
%   model - The name of the model being used
%   diagName - The name of the dialog to be displayed.
%              Options are:
%                   'Solver'
%                   'Data Import/Export'
%                   'Optimizations'
%                   'Diagnostics'
%                   'Hardware Interface'
%                   'Model Referencing'
%                   'Real-Time Workshop'
%                   Workspace Variable
%                   ''
%   tabSel - The name of the RTW tab to display.
%              Options are:
%                   'General'
%                   'Comments'
%                   'Symbols'
%                   'Custom Code'
%                   'Debug'
%                   'Interface'
%                   'Code Style'
%                   'Templates'
%                   'Data Placement'
%                   'Data Type Replacement'
%                   'Memory Sections'
% If you pass only the model argument, the function will open the Model
% Explorer.  If you pass the name of a variable in the Workspace, the Model
% Explorer will open to the base Workspace and that variable will be
% selected.  At the present time, there is no method to select the tab for
% the Diagnostics pane.
%    

%   Copyright 2007 The MathWorks, Inc.


% Get the handles to the dialogs contained in the Model Explorer
%   eDiag == 1 == solver optiosn
%   eDiag == 2 == I/O
%   eDiag == 3 == Optimizations
%   eDiag == 4 == Diagnostiics
%   eDiag == 5 == Hardware implimentation
%   eDiag == 6 == Model Referance
%   eDiag == 7 == RTW
%   eDiag == 8 == html code
%   eDiag == 9 == base workspace data
if exist('diagObj','var')
    evalin('base','delete(diagObj);');
end
[eDiag,diagObj] = getExplorDialogs(model);

switch diagName
    case 'Solver'
        index = 1;
    case 'Data Import/Export'
        index = 2;
    case 'Optimizations'
        index = 3;
    case 'Diagnostics'
        index = 4;
    case 'Hardware Interface'
        index = 5;
    case 'Model Referencing'
        index = 6;
    case 'Real-Time Workshop'
        index = 7;
    case 'HTML'
        index = 8;
    otherwise
        % this is a data case:
        index = -1;
end

if (index == 7) % you specified a tab in the RTW window
    switch tabSel
        case 'General'
            index_T = 0;
        case 'Comments'
            index_T = 1;
        case 'Symbols'
            index_T = 2;
        case 'Custom Code'
            index_T = 3;
        case 'Debug'
            index_T = 4;
        case 'Interface'
            index_T = 5;
        case 'Code Style'
            index_T = 6;
        case 'Templates'
            index_T = 7;
        case 'Data Placement'
            index_T = 8;
        case 'Data Type Replacement'
            index_T = 9;
        case 'Memory Sections'
            index_T = 10;
        otherwise
            index_T = 0;
    end
    diagObj.view(diagObj.getRoot) % Shift to root
    pause(.1); % Allow everything to catch up
    diagObj.view(eDiag{index});
    % Set the active tab
    eDiag{index}.set_param('ActiveTab',index_T);
%     diagObj.show;
else
    try
        % close all model explore instance and open a new one
        if (index > 0)
            diagObj.view(diagObj.getRoot) % Shift to root
            pause(.1); % Allow everything to catch up
            diagObj.view(eDiag{index});
%             diagObj.show;
        else
% data case
            diagObj.view(diagObj.getRoot) % Shift to root
            pause(.1); % Allow everything to catch up
            wsKids = eDiag{9}.getChildren;
% find the variable
            index = findWSKids(wsKids,diagName);
            diagObj.view(wsKids(index)); % 
            pause(.1); % Allow everything to catch up
        end
    catch
        if (pcgDemoData.debug == 1)
            fprintf('error in the open dialog section: %s not found \n',diagName);
        end
    end
end
end

%%
function [index] = findWSKids(wsKids,diagName)
index   = 0;
match   = 0;
numKids = length(wsKids);
while (match == 0) && (index < numKids)
    index = index + 1;
    if (strcmp(wsKids(index).getDisplayLabel,diagName))
        match = 1;
    end
end
end

%%
function [eDiag,diagObj] = getExplorDialogs(curModel)

    %   Input Arguments:
    %   curModel --> The model you want to open dialogs for

    %   eDiag == 1 == solver optiosn
    %   eDiag == 2 == I/O
    %   eDiag == 3 == Optimizations
    %   eDiag == 4 == Diagnostiics
    %   eDiag == 5 == Hardware implimentation
    %   eDiag == 6 == Model Referance
    %   eDiag == 7 == RTW
    %   eDiag == 8 == html code
    %   eDiag == 9 == base workspace data

    % 0.) get base workspace information
    eDiag   = {};
    diagObj = daexplr;
    rootObj = diagObj.getRoot;

    assignin('base','diagObj',diagObj);

    % Get the dialog root for your model
    temp  = rootObj.find('-isa','Simulink.SolverCC'); % 1 solver
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

    configs = getConfigSets(curModel);
    csa = getActiveConfigSet(curModel);
    ActiveCS = csa.getFullName;
    for jj = 1: length(configs) % Loop through the config sets
        if (strcmp([curModel '/' configs{jj}],ActiveCS))
            for inx = 1 : length(eDiag)-1
                eDiag{inx} = eDiag{inx}(jj);
            end
        end
    end
    rootChild    = rootObj.getChildren;
    eDiag{end+1} = rootChild(1); % base workspace

end
