function code_interface_and_support_files(incCodeGenInfo,fileNameInfo)

%   Copyright 1995-2010 The MathWorks, Inc.

    global gTargetInfo gMachineInfo

    if(~gTargetInfo.codingSFunction)
      return;
    end
    if(gTargetInfo.codingDebug)
       code_debug_macros(fileNameInfo);
    end

    % Generate the interface files only when there are no codegen errors
     msgString = sprintf('\nInterface and Support files:\n');
     sf('Private','sf_display','Coder',msgString);

    if(~gTargetInfo.codingLibrary && gTargetInfo.codingSFunction)
        code_machine_registry_file(fileNameInfo);
    end

     lastBuildDate = incCodeGenInfo.infoStruct.date;
     makefileCheckSumChanged = fileNameInfo.auxInfoChanged || ...
                               all([incCodeGenInfo.flags{:}]) ||... %TLTODO: why?
                              (~isequal(incCodeGenInfo.infoStruct.makefileChecksum,...
                                        sf('get',gMachineInfo.machineId,'machine.makefileChecksum')));
                           
     code_rtwtypesdoth(fileNameInfo);
     
     if gTargetInfo.codingWatcomMakefile
         if makefileCheckSumChanged || ...
            ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.watcomMakeFile),lastBuildDate)
             code_watcom_make_file(fileNameInfo);
         end
     end
     if gTargetInfo.codingBorlandMakefile
         if makefileCheckSumChanged || ...
            ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.borlandMakeFile),lastBuildDate)
             code_borland_make_file(fileNameInfo);
         end
         if makefileCheckSumChanged || ...
            ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.machineDefFile),lastBuildDate)
             code_machine_def_file(fileNameInfo,1);
         end
     end
     if gTargetInfo.codingIntelMakefile
         if makefileCheckSumChanged || ...
            ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.intelMakeFile),lastBuildDate)
             code_intel_make_file(fileNameInfo);
         end
     end
     if gTargetInfo.codingMSVCMakefile
         if makefileCheckSumChanged || ...
            ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.msvcMakeFile),lastBuildDate)
             code_msvc_make_file(fileNameInfo);
         end
     end
     if sf('Feature','Developer')
         if makefileCheckSumChanged || ...
            ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.msvcdspFile),lastBuildDate)
             code_msvc_dspfile(fileNameInfo);
             code_msvc_dswfile(fileNameInfo);
         end
     end
     if gTargetInfo.codingUnixMakefile
         if makefileCheckSumChanged || ...
            ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.unixMakeFile),lastBuildDate)
             code_unix_make_file(fileNameInfo);
         end
     end

     if (~isunix && gTargetInfo.codingLccMakefile && ...
         ~gTargetInfo.codingMSVCMakefile && ...
         ~gTargetInfo.codingIntelMakefile && ...
         ~gTargetInfo.codingBorlandMakefile && ...
         ~gTargetInfo.codingWatcomMakefile)
         if makefileCheckSumChanged || ...
            ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.lccMakeFile),lastBuildDate)
             code_lcc_make_file(fileNameInfo);
         end
     end

    sf('Private','sf_display','Coder',sprintf('\n'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function code_rtwtypesdoth(fileNameInfo)
global gTargetInfo 

hardwareImp = rtwhostwordlengths();
hardwareImpProps = rtw_host_implementation_props();
fNames = fieldnames(hardwareImpProps);
for i=1:length(fNames)
    hardwareImp.(fNames{i}) = hardwareImpProps.(fNames{i});
end
hardwareImp.HWDeviceType = 'Generic->MATLAB Host Computer';
        
hardwareDeploy = [];
hardwareDeploy.CharNumBits = hardwareImp.CharNumBits;
hardwareDeploy.ShortNumBits = hardwareImp.ShortNumBits;
hardwareDeploy.IntNumBits = hardwareImp.IntNumBits;
hardwareDeploy.LongNumBits = hardwareImp.LongNumBits;
hardwareDeploy.FloatNumBits = hardwareImp.FloatNumBits;
hardwareDeploy.DoubleNumBits = hardwareImp.DoubleNumBits;
hardwareDeploy.PointerNumBits = hardwareImp.PointerNumBits;
        
configInfo = [];
configInfo.GenDirectory = fileNameInfo.targetDirName;
configInfo.PurelyIntegerCode = gTargetInfo.codingIntegerCodeOnly;
configInfo.SupportComplex = ~gTargetInfo.codingRealCodeOnly;
configInfo.MaxMultiwordBits = 1024;
        
simulinkInfo = [];
simulinkInfo.Style = 'full';
simulinkInfo.SharedLocation = false;
simulinkInfo.IsERT = false;
simulinkInfo.PortableWordSizes = false;
simulinkInfo.SupportNonInlinedSFcns = false;
simulinkInfo.GRTInterface = false;
simulinkInfo.ReplacementTypesOn = false;
simulinkInfo.ReplacementTypesStruct = [];
simulinkInfo.GenChunkDefs = false;
simulinkInfo.GenBuiltInDTEnums = false;
simulinkInfo.MatFileLogging = false;
simulinkInfo.GenTimingBridge = false;
        
genRTWTYPESDOTH(hardwareImp,hardwareDeploy,configInfo,simulinkInfo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = check_if_file_is_in_sync(fileName,buildDate)

result = sf('Private','check_if_file_is_in_sync',fileName,buildDate);
