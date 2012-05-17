function incCodeGenInfo = compute_inc_codegen_info(fileNameInfo,codingRebuildAll)

global gMachineInfo gTargetInfo

if(isunix)
    libext = 'a';
else
    libext = 'lib';
end

numCharts = length(gMachineInfo.charts);
incCodeGenInfo.flags = cell(1, numCharts);
for i = 1:numCharts
    numSpecs = length(gMachineInfo.specializations{i});
    incCodeGenInfo.flags{i} = ones(1, numSpecs);
end
incCodeGenInfo.infoStruct = [];

if(~gTargetInfo.codingLibrary && gTargetInfo.codingSFunction)
    infoStruct = sf('Private','infomatman','load','dll',gMachineInfo.machineId,gMachineInfo.mainMachineId,gMachineInfo.targetName);
else
    infoStruct = sf('Private','infomatman','load','binary',gMachineInfo.machineId,gMachineInfo.mainMachineId,gMachineInfo.targetName);
end

try
    lastBuildDate = infoStruct.date;
catch ME %#ok<NASGU>
    infoStruct.date = 0.0;
    lastBuildDate = 0.0;
end
regenerateCodeForallCharts = codingRebuildAll;

%TLTODO: Verify following logic is not needed
%if(~regenerateCodeForallCharts)
%    if(gTargetInfo.codingLibrary && gTargetInfo.codingSFunction)
%        regenerateCodeForallCharts = ~exist([gMachineInfo.machineName,'_',gMachineInfo.targetName,'.',libext],'file');
%    end
%end

if(~regenerateCodeForallCharts)
    regenerateCodeForallCharts = ~isequal(infoStruct.machineChecksum,sf('get',gMachineInfo.machineId,'machine.checksum'));
end

if(~regenerateCodeForallCharts)
    regenerateCodeForallCharts = ~isequal(infoStruct.exportedFcnChecksum,sf('get',gMachineInfo.machineId,'machine.exportedFcnChecksum'));
end

if(~regenerateCodeForallCharts)
    regenerateCodeForallCharts = ~isequal(infoStruct.targetChecksum,sf('get',gMachineInfo.target,'target.checksumSelf'));
end
if((gTargetInfo.codingSFunction || gTargetInfo.codingRTW) && regenerateCodeForallCharts)
   clean_code_gen_dir(fileNameInfo.targetDirName);
end

incCodeGenInfo.infoStruct = infoStruct;

if(regenerateCodeForallCharts)
   return;
end

for i = 1:length(gMachineInfo.charts)
    chart = gMachineInfo.charts(i);
    [chartNumber,chartFileNumber] = sf('get',chart,'chart.number','chart.chartFileNumber');
    index = find(infoStruct.chartFileNumbers==chartFileNumber);
    forceRebuildChart = false;
    if ~isempty(index)
        forceRebuildChart = infoStruct.forceRebuildChartFlags(index);
    end

    if forceRebuildChart
        continue;
    end

    numSpecs = length(gMachineInfo.specializations{i});
    for j = 1:numSpecs
        if gTargetInfo.codingSFunction || gTargetInfo.codingRTW
            sourceFileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartSourceFiles{chartNumber+1}{j});
            headerFileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartHeaderFiles{chartNumber+1}{j});
        else
            sourceFileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartSourceFiles{chartNumber+1});
            headerFileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartHeaderFiles{chartNumber+1});
        end

        if(~regenerateCodeForallCharts && ...
           check_if_file_is_in_sync(sourceFileName,lastBuildDate) && ...
           check_if_file_is_in_sync(headerFileName,lastBuildDate))
            if numSpecs == 1
                checksum = [];
                if(~isempty(index))
                    checksum = infoStruct.chartChecksums(index,:);
                end
                regenerateCodeForThisChart = ~isequal(checksum,sf('get',chart,'chart.checksum'));
            else
                regenerateCodeForThisChart = 0;
            end
        else
            regenerateCodeForThisChart = 1;
        end
        if(~regenerateCodeForThisChart)
            incCodeGenInfo.flags{i}(j) = 0;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = check_if_file_is_in_sync(fileName,buildDate)

result = sf('Private','check_if_file_is_in_sync',fileName,buildDate);
