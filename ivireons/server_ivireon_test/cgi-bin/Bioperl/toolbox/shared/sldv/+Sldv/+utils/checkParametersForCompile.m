function parameterSettings = checkParametersForCompile(model, parameterSettings)

%   Copyright 2010 The MathWorks, Inc.

    newparameterSettings = parameterSettings;
    parametersToChange = fieldnames(parameterSettings);
    for idx=1:length(parametersToChange)
        newparamConfig = parameterSettings.(parametersToChange{idx});
        actualParamValue = get_param(model, parametersToChange{idx});
        if ~strcmp(actualParamValue,newparamConfig.newvalue)
            set_param(model, parametersToChange{idx}, newparamConfig.newvalue);
            newparameterSettings.(parametersToChange{idx}).originalvalue = actualParamValue;
        else
            newparameterSettings = rmfield(newparameterSettings,parametersToChange{idx});
        end
    end        
    parameterSettings = newparameterSettings;
end