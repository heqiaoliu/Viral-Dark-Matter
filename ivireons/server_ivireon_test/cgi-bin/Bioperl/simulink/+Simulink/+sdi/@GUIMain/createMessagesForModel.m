function createMessagesForModel(this, modelName)
    % Copyright 2010 The MathWorks, Inc.
    
    try
        % get the active configset
        configset = getActiveConfigSet(modelName);
        singleOutput = get_param(configset,'ReturnWorkspaceOutputs');
        singleOutput = strcmp(singleOutput, 'on');
        
        saveState = get_param(configset,'SaveState');
        saveState = strcmp(saveState, 'on');
        
        saveOutput = get_param(configset,'SaveOutput');
        saveOutput = strcmp(saveOutput, 'on');
        
        saveFinalState = get_param(configset,'SaveFinalState');
        saveFinalState = strcmp(saveFinalState, 'on');
        
        sigLogging = get_param(configset,'SignalLogging');
        sigLogging = strcmp(sigLogging, 'on');
        
        dsmLogging = get_param(configset,'DSMLogging');
        dsmLogging = strcmp(dsmLogging, 'on');
        
        saveTime = get_param(configset,'SaveTime');
        saveTime = strcmp(saveTime, 'on');
        
        saveFormat = get_param(configset,'SaveFormat');
        titleString = DAStudio.message('SDI:sdi:mgSDINoLoggedDataTitle');
        
        isSignalLogging = get_param(modelName, 'ModelSignalLogs');
        
        if (isempty(isSignalLogging) && sigLogging)
            messageString = DAStudio.message('SDI:sdi:mgSDISigLoggingNoData');
            helperOpenMessage(messageString, titleString);
            % don't look further as already a message is up
            return;
        end
        
        if (~saveState && ~saveOutput && ~saveFinalState...
                && ~sigLogging && ~dsmLogging)
            messageString = DAStudio.message('SDI:sdi:mgSDINoLoggedData',...
                                              modelName);
            helperOpenMessage(messageString, titleString);
            % don't look further as already a message is up
            return;
        end
        
        if strcmpi(saveFormat, 'Array') || strcmpi(saveFormat, 'Structure')
            messageString = DAStudio.message('SDI:sdi:mgSDIOutputArray',...
                                              modelName);
            helperOpenMessage(messageString, titleString);
            % don't look further as already a message is up
            return;
        else
            messageString = DAStudio.message('SDI:sdi:mgSDISigLoggingNoData');
            helperOpenMessage(messageString, titleString);
            % don't look further as already a message is up
            return;
        end
        
    catch %#ok
        % don't do anything if you cannot find the model
    end
    
end
        
function helperOpenMessage(messageString, titleString)
    h = helpdlg(messageString, titleString);
    children = get(h, 'children');
    uibutton = findall(children, 'type', 'uicontrol');
    % open the help page and close the uicontrol
    set(uibutton, 'String', 'Help', 'Callback',...
        'close(gcbf);helpview([docroot ''/toolbox/simulink/helptargets.map''], ''simulation_data_inspector'')');
end