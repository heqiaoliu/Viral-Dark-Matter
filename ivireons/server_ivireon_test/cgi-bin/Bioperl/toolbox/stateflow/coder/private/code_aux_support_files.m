function fileNameInfo = code_aux_support_files(fileNameInfo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handle auxiliary build dependencies from TFL and EML
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global gMachineInfo gTargetInfo

tflControl = get_param(gMachineInfo.mainMachineName, ...
            'SimTargetFcnLibHandle');
tflControl.runFcnImpCallbacks(gMachineInfo.targetName, [], ...
            fileNameInfo.targetDirName);

infoStruct = sfprivate('infomatman','load','binary',...
    gMachineInfo.machineId,gMachineInfo.mainMachineId,...
    gMachineInfo.targetName);
hasInfo = isfield(infoStruct, 'chartInfo') && ...
    isfield(infoStruct.chartInfo, 'auxBuildInfo');
chartFileNumbers = sf('get',gMachineInfo.charts,'chart.chartFileNumber');

% The new dependency set is the union of the dependencies for the charts in
% the current cache (those compiled in this build) and the charts not in 
% the cache but in the infomat structure. 
% This is the set needed for the current build.
newAuxInfo = auxInfoConstruct();
for chartIdx = 1:length(gMachineInfo.charts)
    chartId = gMachineInfo.charts(chartIdx);
    % Look in the cache
    [found auxInfo] = sfprivate('auxInfoChartCache','get',chartId);
    if ~found && hasInfo
        % No data in the cache: look in the infomat structure for this
        % chart's dependencies
        chartFileNumber = chartFileNumbers(chartIdx);
        infoIndex = find(infoStruct.chartFileNumbers==chartFileNumber);
        if ~isempty(infoIndex)
            % We should always get here: the file dependency list should 
            % either be in the cache or in the infomat structure
            auxInfo = infoStruct.chartInfo(infoIndex).auxBuildInfo;
        end
    end
    if isstruct(auxInfo)
        sfprivate('auxInfoCopyToBuildDir', auxInfo, fileNameInfo.targetDirName);
        newAuxInfo = auxInfoUpdate(newAuxInfo, auxInfo);
    else
        newAuxInfo.sourceFiles = [newAuxInfo.sourceFiles auxInfo];
    end
end

if gTargetInfo.codingSFunction && ~gTargetInfo.codingLibrary
    for i = 1:length(fileNameInfo.linkMachines)
        libInfoStruct = sf('Private','infomatman','load','binary',fileNameInfo.linkMachines{i},gMachineInfo.mainMachineId,gMachineInfo.targetName);
        if isfield(libInfoStruct, 'linkFlags') && ~isempty(libInfoStruct.linkFlags)
            newAuxInfo.linkFlags = [newAuxInfo.linkFlags libInfoStruct.linkFlags];
        end
    end
end

newAuxInfo = sfprivate('auxInfoUnique',newAuxInfo);

% The old dependency set is retrieved from the infomat structure. 
% This is the set used for the previous (successful) build.
oldAuxInfo = auxInfoConstruct();
if hasInfo
    auxInfos = [infoStruct.chartInfo(:).auxBuildInfo];
    if isstruct(auxInfos)
        for i=1:numel(auxInfos)
            auxInfo = auxInfos(i);
            oldAuxInfo = auxInfoUpdate(oldAuxInfo, auxInfo);
        end
    else
        oldAuxInfo.sourceFiles = [oldAuxInfo.sourceFiles auxInfos];
    end
end

if gTargetInfo.codingSFunction && ~gTargetInfo.codingLibrary
    if ~isempty(infoStruct) && isfield(infoStruct, 'linkFlags')
        oldAuxInfo.linkFlags = infoStruct.linkFlags;
    end
end

oldAuxInfo = sfprivate('auxInfoUnique',oldAuxInfo);

fileNameInfo.auxInfoChanged = ...
    ~isequal(newAuxInfo.sourceFiles, oldAuxInfo.sourceFiles) || ...
    ~isequal(newAuxInfo.linkObjects, oldAuxInfo.linkObjects) || ...
    ~isequal(newAuxInfo.linkFlags, oldAuxInfo.linkFlags);

fileNameInfo.auxInfo = newAuxInfo;

% Function: emptyAuxInfoStruct ============================================
% Create an empty aux-info structure.
function emptyInfo = auxInfoConstruct()
emptyInfo = sfprivate('auxInfoConstruct');    

% Function: auxInfoUpdate =================================================
% The aux info consist of an array of structures; this function returns
% a single structure with one field for each class of auxiliary info 
% containing a cell array of strings.
function auxInfoSum = auxInfoUpdate(auxInfoSum, auxInfo)
auxInfoSum = sfprivate('auxInfoUpdate', auxInfoSum, auxInfo);    
