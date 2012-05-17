function  isEmlBasedChart = is_eml_based_chart(id)
% Copyright 2004-2005 The MathWorks, Inc.

isEmlBasedChart = is_eml_chart(id) || is_eml_truth_table_chart(id);
    
return;
