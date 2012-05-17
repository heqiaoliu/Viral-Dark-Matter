function pcgd_open_dialog(digName,tabSel,stage)
    % This function opens a given dialog in the model explorer

%   Copyright 2007-2008 The MathWorks, Inc.

    % 0.) Get the base data
    [pcgDemoData] = RTWDemos.pcgd_startEmbeddedCoderOverview;
    % first check for open dialogs
    
    % 1.) Verify that the model is open
    [pcgDemoData] = RTWDemos.pcgd_modelIsOpen(pcgDemoData,stage);
    
    % 2.) Translate the sort hand into the actual page
    %   eDiag == 1 == solver optiosn
    %   eDiag == 2 == I/O
    %   eDiag == 3 == Optimizations
    %   eDiag == 4 == Diagnostiics
    %   eDiag == 5 == Hardware implimentation
    %   eDiag == 6 == Model Referance
    %   eDiag == 7 == RTW 
    %   eDiag == 8 == html code
    %   eDiag == 9 == workspace data
    
    switch digName
        case 'HI'
            index = 5;
        case 'RTW'
            index = 7;
        case 'OPT'
            index = 3;
        case 'SOL'
            index = 1;
        case 'HTML'
            index = 8;
        otherwise 
            % this is a data case:
            index = -1;
    end
    [eDiag,pcgDemoData] = RTWDemos.pcgd_getExplorDialogs(pcgDemoData,stage);            
    if (index ~= 7)
        try
            % close all model explore instance and open a new one
            if (index > 0)
%                pcgDemoData.explrDiag.view(pcgDemoData.explrDiag.getRoot) % Shift to root
                pause(.1); % Allow everything to catch up
                pcgDemoData.explrDiag.view(eDiag{index});                
            else
                % data case
%                pcgDemoData.explrDiag.view(pcgDemoData.explrDiag.getRoot) % Shift to root
                pause(.1); % Allow everything to catch up
                wsKids = eDiag{9}.getChildren;
                % find the variable
                index = findWSKids(wsKids,digName);
                pcgDemoData.explrDiag.view(wsKids(index)); % 
                pause(.1); % Allow everything to catch up                
            end
        catch % The dialog could not be opened.
            if (pcgDemoData.debug == 1)
                fprintf('error in the open dialog section: %s not found \n',digName);
            end
        end
    elseif (index == 7) 
        % you specified a tab in the RTW window
        switch tabSel
            case 'GEN'% General
                index_T = 0;
            case 'COM' % Comments
                index_T = 2;
            case 'SYM' % Symbols
                index_T = 3;
            case 'CUS' % Custom Code
                index_T = 4;
            case 'DEB' % Debug
                index_T = 5;
            case 'INT' % Interface
                index_T = 6;
            case 'COD' % code Style
                index_T = 7;
            case 'TEM' % Templates
                index_T = 8;
            case 'DAT' % Data Placment
                index_T = 9;
            case 'DTR' % Data Type Replacment
                index_T = 10;
            case 'MEM' % Memory Sections
                index_T = 11;
            otherwise
                index_T = 0;
        end
%        pcgDemoData.explrDiag.view(pcgDemoData.explrDiag.getRoot) % Shift to root
        pause(.1); % Allow everything to catch up
        pcgDemoData.explrDiag.view(eDiag{index});
        % Set the active tab
        eDiag{index}.set_param('ActiveTab',index_T);
    end % ends the if (nargin == 1) / elseif (nargin == 2) && (index == 7)
    % Save off the data
    assignin('base','pcgDemoData',pcgDemoData);
end

function [index] = findWSKids(wsKids,digName)
    index   = 0;
    match   = 0;
    numKids = length(wsKids);
    while (match == 0) && (index < numKids)
        index = index + 1;
        if (strcmp(wsKids(index).getDisplayLabel,digName))
            match = 1;
        end
    end
end
