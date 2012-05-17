function sl_refresh_customizations
% SL_REFRESH_CUSTOMIZATIONS Refreshes Simulink menu and dialog customizations.
%
% SL_REFRESH_CUSTOMIZATIONS searches the MATLAB path for files named
% sl_customization.m and executes each file, passing it a handle to the
% Customization Manager. Simulink runs SL_REFRESH_CUSTOMIZATIONS at
% the start of every Simulink session. To activate a customization (i.e.,
% execute an sl_customization.m file) created later in the same session, you  
% must invoke SL_REFRESH_CUSTOMIZATIONS yourself. 
%
% Example:
%    sl_refresh_customizations;
%
% For more information, see <a href="matlab: helpview([docroot '/mapfiles/simulink.map'], 'customize_gui')">Customizing the Simulink User Interface</a>.
%
% See also SL_ACTION_SCHEMA, SL_TOGGLE_SCHEMA, SL_CONTAINER_SCHEMA.

% Copyright 1990-2010 The MathWorks, Inc.

    % make sure we load Simulink before actually doing
    % customization.  This will help with problems where
    % customizations try to load Simulink classes.  Loading
    % Simulink will try run this file, so put some logic to
    % prevent this reentrancy.
    persistent reentrant;
    
    if ~isempty(reentrant)
        return;
    end
    
    cm = DAStudio.CustomizationManager;
    if ~cm.isEnabled
        disp('Customizations not refreshed because the CustomizationManager has been disabled.');
        return;
    end
    
    reentrant = 1; %#ok

    load_simulink;
    reentrant = [];
    
    % SLPerfTools.Tracer.logSLStartupData will ONLY log data if the
    % user has called: SLPerfTools.Tracer.enableSLStartupLogging(true);
    % Without this feature being enabled, no logging will occur
    SLPerfTools.Tracer.logSLStartupData('sl_refresh_customizations', true);

    currentDir = pwd;
    cm = DAStudio.CustomizationManager;
    
    cm.clearCustomizers;
    cm.clearDlgPreOpenFcns;
    cm.clearCustomMenuFcns;
    cm.clearCustomFilterFcns;
    cm.clearModelAdvisorCheckFcns;
    cm.clearModelAdvisorTaskFcns;
    cm.clearModelAdvisorProcessFcns;
    cm.clearModelAdvisorTaskAdvisorFcns;
    cm.clearSigScopeMgrViewerLibraries;
    cm.clearSigScopeMgrGeneratorLibraries;

    % Force data classes to use UDD/MCOS correctly.
    sldataclasssetup;

    % clear Model Advisor objects
    maroot = ModelAdvisor.Root;
    maroot.clear;
    
    try
        call_all( 'sl_internal_customization', cm );
        cd(currentDir);
        call_all( 'sl_customization', cm );
    catch me
        warning(me.identifier, '%s', me.message);
    end

    cd(currentDir);
    cm.updateEditors;
    SLPerfTools.Tracer.logSLStartupData('sl_refresh_customizations', false);
end

function call_all( fileName, cm )
    phaseStr = ['which(''-all'', ' fileName, ')'];
    SLPerfTools.Tracer.logSLStartupData(phaseStr,true);
    customizations = which('-all', fileName);
    SLPerfTools.Tracer.logSLStartupData(phaseStr, false);
    
    SLPerfTools.Tracer.logSLStartupData(fileName, true);

    preCallStr = [fileName '_pre_call'];
    SLPerfTools.Tracer.logSLStartupData(preCallStr, true);
    if length(customizations) == 0 %#ok
        % close off the started phases for completeness
        SLPerfTools.Tracer.logSLStartupData(preCallStr, false);
        SLPerfTools.Tracer.logSLStartupData(fileName, false);
        return
    end

    phaseStr = [fileName '_fileparts_loop'];
    SLPerfTools.Tracer.logSLStartupData(phaseStr, true);
    for i=1:length(customizations)
        paths{i} = fileparts(customizations{i}); %#ok
    end
    SLPerfTools.Tracer.logSLStartupData(phaseStr, false);

    phaseStr = [fileName '_unique'];
    SLPerfTools.Tracer.logSLStartupData(phaseStr, true);
    paths = unique(paths);
    SLPerfTools.Tracer.logSLStartupData(phaseStr, false);

    % Cache function handles to various functions we're going to 
    % call.  This will at least keep us from changing directories
    % for too long.
    phaseStr = [fileName '_str2func_loop'];
    SLPerfTools.Tracer.logSLStartupData(phaseStr, true);
    currentDir = pwd;
    for i=1:length(paths)
        cd(paths{i});
        
        funcs{i} = str2func(fileName); %#ok
    end
    SLPerfTools.Tracer.logSLStartupData(phaseStr,false);

    phaseStr = [fileName '_change_dir'];
    SLPerfTools.Tracer.logSLStartupData(phaseStr,true);
    cd(currentDir);
    SLPerfTools.Tracer.logSLStartupData(phaseStr,false);
    
    SLPerfTools.Tracer.logSLStartupData(preCallStr,false);
    
    % Now actually call all the various functions, from the current
    % directory.
    for i=1:length(funcs)
        try
            if strcmp(fileName, 'sl_customization') && usejava('jvm') > 0 && ...
                    exist('rtw.codegenObjectives.ObjectiveCustomizer', 'class') > 0
                try
                    cm.ObjectiveCustomizer.currentCustomizationFile = paths{i};
                catch ME
                end
            end
            customizationString = fullfile(paths{i}, fileName);
            SLPerfTools.Tracer.logSLStartupData(customizationString,true);
            feval(funcs{i},cm);
            SLPerfTools.Tracer.logSLStartupData(customizationString, false);
        catch me
            warning(me.identifier, '%s', me.message);
        end
    end
    
    SLPerfTools.Tracer.logSLStartupData(fileName, false);
end

%EOF

% LocalWords:  reentrancy Perf func Customizer
