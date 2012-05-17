function wkspData = get_wksp_data_for_chart(chartId)
% returns all data in the chart that are
% init from workspace. Skip those that have ml datatype.
% These should not be registered as simulink params
% for two reasons: 1. these are used only for simulation
% 2. the init values for the ml vars can be any MATLAB 
% data, not just matrices allowed by Simulink.

% Copyright 2002-2009 The MathWorks, Inc.

allData = sf('DataIn',chartId);
paramData = sf('find',allData,'data.scope','PARAMETER_DATA');
if is_eml_based_chart(chartId)
    % EML based charts (EML blocks, TT blocks) ignore the
    % .initFromWorkspace setting, so we should not treat them as params.
    outputData = [];
else
    outputData = sf('find',allData,'data.scope','OUTPUT_DATA','data.initFromWorkspace',1,'data.props.resolveToSignalObject',0);
end
localData = sf('find',allData,'data.scope','LOCAL_DATA','data.initFromWorkspace',1,'data.props.resolveToSignalObject',0);
fcnOutputData = sf('find',allData,'data.scope','FUNCTION_OUTPUT_DATA','data.initFromWorkspace',1);
tempData = sf('find',allData,'data.scope','TEMPORARY_DATA','data.initFromWorkspace',1);

wkspData = [outputData localData fcnOutputData tempData];
wkspData = sf('find',wkspData,'~data.props.type.primitive','SF_MATLAB_TYPE');

% we check for parameters of MATLAB type and throw an error during parsing;
% so we can add all parameters back again here
wkspData = [paramData wkspData];
