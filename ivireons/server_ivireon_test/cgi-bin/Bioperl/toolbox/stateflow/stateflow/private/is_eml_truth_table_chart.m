function result = is_eml_truth_table_chart(chartId)

% Copyright 2004-2005 The MathWorks, Inc.

result = false;

if is_truth_table_chart(chartId)
    ttFcn = truth_tables_in(chartId);
    if length(ttFcn) == 1 && is_eml_truth_table_fcn(ttFcn)
        result = true;
    end
end
        
return;
    