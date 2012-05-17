function sl_internal_customization(cm)

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.6.12 $

    persistent obj;
    persistent busEditorCustomizer;
    persistent objectiveCustomizer;        
    persistent lutTableCustomizer; 
    
    if (isempty(obj))
        obj = Simulink.ExtModeTransports;
    end
    
    if (isempty(busEditorCustomizer))
        busEditorCustomizer = BusEditor.customizer;
    end
        
    inheritRuleCustomizer = Simulink.InheritRuleCustomizer.getCustomizer();
    inheritRuleCustomizer.clearCustomRules();
    
    lutTableCustomizer = Simulink.LookupTableEditorCustomizer();
    cm.addCustomizer('LookupTableEditorCustomizer', lutTableCustomizer);

    dataTypeCustomizer = Simulink.DataTypeCustomizer.getCustomizer();
    % dataTypeCustomizer could be empty if the customization is featured off.
    % In this case, do not register the customizer.
    if (~isempty(dataTypeCustomizer)) 
        dataTypeCustomizer.resetDataTypes();
        cm.addCustomizer('DataTypeCustomizer', dataTypeCustomizer);
    end
      
    OCInitSuccess = false;
    if (isempty(objectiveCustomizer))
        if usejava('jvm') > 0
            if exist('rtw.codegenObjectives.ObjectiveCustomizer', 'class') > 0
                objectiveCustomizer = rtw.codegenObjectives.ObjectiveCustomizer;
                OCInitSuccess = true;
            end
        end
    else
        OCInitSuccess = true;
    end

    obj.clear();
    cm.addCustomizer('ExtModeTransports',obj);
    
    busEditorCustomizer.clear();    
    cm.addCustomizer('BusEditorCustomizer', busEditorCustomizer);    

    cm.addCustomizer('InheritRuleCustomizer', inheritRuleCustomizer);

    if( LibraryBrowser.StandaloneBrowser.hasDisplay() );
        LBCustomizer.getInstance().clear();
        cm.addCustomizer('LibraryBrowserCustomizer', LBCustomizer.getInstance());    
    end

    if OCInitSuccess
        objectiveCustomizer.clear();
        cm.addCustomizer('ObjectiveCustomizer', objectiveCustomizer);
    end

