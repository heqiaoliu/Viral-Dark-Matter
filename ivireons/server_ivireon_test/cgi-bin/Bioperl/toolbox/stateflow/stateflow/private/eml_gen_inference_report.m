%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the EML inference report
function eml_gen_inference_report(iReport,passed,chartId,hBlk,machineId,mainMachineName,machineName)

%   Copyright 2009 The MathWorks, Inc.

spec = sf('SFunctionSpecialization', chartId, hBlk);
if isempty(spec)
    % If spec checksum is not ready, use block path as checksum.
    spec = sf('MD5AsString', getfullname(hBlk));
end

modeldir = pwd;
targetName = 'sfun';
[~, htmlDirArray] = get_sf_proj(modeldir,mainMachineName,machineName,targetName,'html');
srcDirPath = get_sf_proj(modeldir,mainMachineName,machineName,targetName,'src');
chartFileNumber = sf('get',chartId,'chart.chartFileNumber');
chartFileNumberStr = num2str(chartFileNumber);
reportName = ['chart' chartFileNumberStr '_' spec];
htmlDirArray{end+1} = reportName;
htmlDirPath = create_directory_path(htmlDirArray{:});
summary = struct(...
    'directory', srcDirPath, ...
    'htmldirectory', htmlDirPath, ...
    'passed', passed);
report = struct(...
    'summary', summary, ...
    'inference', iReport); %#ok<NASGU>
[~,infoDirArray] = get_sf_proj(modeldir,mainMachineName,machineName,targetName,'info');
infoDirPath = create_directory_path(infoDirArray{:});
mainInfoName = fullfile(infoDirPath, [reportName '.mat']);
save(mainInfoName,'report');

if ~passed
    targetId = acquire_target(machineId, targetName);
    targetman('delete_target_sfunction_func', targetId,0,0, [],[],machineId);
end


