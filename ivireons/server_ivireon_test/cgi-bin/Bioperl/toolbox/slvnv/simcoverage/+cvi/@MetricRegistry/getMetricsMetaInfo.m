
%   Copyright 2010 The MathWorks, Inc.

% dialogLabel (string) (MCDC, Condition, Simulink Design Verifier)
% cvtestFieldName (string) (eg mcdc, condition, decision)
% accessCommand (string) command for extracting from cvdata (eg decisioninfo, mcdcinfo)
% metricSetting (string) 1 character short name
% gridRow 1 at the top
% gridColumn 1 at the left 
function metricData = getMetricsMetaInfo    

    data = cvi.MetricRegistry.getMetricDescrTable;
    metricData = [];
    fn =  fieldnames(data);
    for idx = 1:numel(fn)
        cfn = fn{idx};
        st = [];
        st.dialogLabel = data.(cfn){1}; 
        st.cvtestFieldName = data.(cfn){3}; 
        st.accessCommand = data.(cfn){6};         
        st.metricSetting  = data.(cfn){2}; 
        st.gridRow = data.(cfn){7}; 
        st.gridColumn = data.(cfn){8}; 
        if strcmpi(st.cvtestFieldName, 'testobjectives')
            st.cvtestFieldName = 'designverifier';
        end
        if isempty(metricData)
            metricData = st; 
        else
            metricData(end+1) = st;  %#ok<AGROW>
        end
    end
    
