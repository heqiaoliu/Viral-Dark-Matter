
%   Copyright 2009 The MathWorks, Inc.

function enumValStruct = getAllEnums()      
enumValStruct = [];
enumValStruct = getEnumStruct(enumValStruct, cvi.MetricRegistry.getMetricDescrTable);
enumValStruct = getEnumStruct(enumValStruct, cvi.MetricRegistry.getGenericMetricMap);

%=================================
function enumValStruct = getEnumStruct(enumValStruct, dt)
fn =  fieldnames(dt);
for idx = 1:numel(fn)
    cfn = fn{idx};
    if isfield(dt, cfn)
       enumValStruct.(cfn) = dt.(cfn){4}; 
    else
        dt = cvi.MetricRegistry.getSldvMetricDescrTable(mn);        
        if isfield(dt, cfn)
            enumValStruct.(cfn) = dt.(mn){4}; 
        end
    end
end

