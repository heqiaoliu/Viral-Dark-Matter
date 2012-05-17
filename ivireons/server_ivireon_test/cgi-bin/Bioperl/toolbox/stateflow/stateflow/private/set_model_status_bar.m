function set_model_status_bar(modelName,statusText)

if(nargin<2)
    statusText = '';
end

if(~ischar(modelName))
    modelName = sf('get',modelName,'machine.name');
end
if(strcmp(get_param(modelName,'BlockDiagramType'),'model'))
    %  protect this call which errors out for libraries.
    set_param(modelName,'StatusString',statusText);
end
return;