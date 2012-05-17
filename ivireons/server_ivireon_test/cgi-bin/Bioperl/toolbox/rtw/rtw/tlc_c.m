function buildResult = tlc_c(h,...
                          modelName, rtwroot, systemTargetFile, ...
                          dispOpts, buildDir, codeFormat, ...
                          iMdlRefBuildArgs, anchorDir, iChecksum) %#ok
  %TLC_C Private Real-Time Workshop function to generate C code from a model.
  %
  % This is a back-end function for use with the Real-Time Workshop.
  % It is not intended to be directly used or modified. This function is
  % responsible for managing the creation of the *.c and *.h files in the
  % Real-Time Workshop build directory. It will also remove old *.c and *.h
  % files.
  %
  % The normal operation of the Real-Time Workshop assumes that all *.c and *.h
  % files with in the Real-Time Workshop build directory are created during the
  % the TLC process of the Real-Time Workshop build procedure. Third-party
  % targets may also create *.c and *.h files in the build directory. To
  % prevent the Real-Time Workshop from deleting or altering these files,
  % they must be explicitly marked as target specific files by the presence
  % of the string 'target specific file' in the first line of the *.c or *.h
  % file. For example,
  %
  %      /*  COMPANY-NAME target specific file
  %       *
  %       *    This file is created for use with the COMPANY-NAME target. It
  %       *    is used for ...
  %       */
  %      ...
  %
  % This function is designed to be invoked by make_rtw.
  % All arguments (modelName, rtwroot, systemTargetFile, RTWVerbose,
  % buildDir, codeFormat, etc) are assumed to be present.
  %
  % TLC_C uses rtwgen to generate the model.rtw file which is then converted
  % to C code by the Target Language Compiler.
  %
  % Returns a structure with the following fields:
  %  buildResult.rtwFile
  %       The name of the generated model.rtw file.
  %  buildResult.modules
  %       A string list of additional C modules that were
  %       created excluding the model.c file.
  %  buildResult.noninlinedSFcns
  %       A cell array of S-functions to be compiled and linked with.
  %  buildResult.listSFcns
  %       A cell array of inlined and noninlined S-functions.
  %  buildResult.noninlinednonSFcns
  %       A cell array of functions to be compiled and linked with.
  %  buildResult.buildNotNeeded
  %       A boolean indicating the build was not needed because the
  %       generated code was up to date.
  %  buildResult.runTimeParameters
  %       A structure with information pertaining to the model parameters
  %       that did not affect the structural checksum
  
  % See also MAKE_RTW.



  %    Copyright 1994-2010 The MathWorks, Inc.
  %    $Revision: 1.147.4.69 $ $Date: 2010/05/20 02:52:17 $

  %-------------------------------------------%
  % If we have stateflow S-functions, build   %
  % the .tlc files for Version 1.1 and later. %
  % Version 1.06 generates C code             %
  % Do this before rtwgen call so that SF can %
  % cache away optimization info.
  %-------------------------------------------%

  profileOn     = iMdlRefBuildArgs.slbuildProfileIsOn;
  mdlRefTgtType = iMdlRefBuildArgs.ModelReferenceTargetType;

  slprivate('slbuild_profile', modelName, 'log', 'tlc_c: start', ...
            profileOn, mdlRefTgtType);

  if isempty(buildDir)
      % This should never occur - make_rtw issues an error if buildDir
      % wasn't specified in the system target file.
      assertMsg = 'Fatal error, buildDir passed to tlc_c is empty';
      assert(false,assertMsg);
  end

  %---------------------------------------------------------------------------%
  % create the TFL instance (if it doesn't exist), then clear all of the usage%
  % counts on the Function implementations.  This must be done prior to       %
  % rtwgen(), because the actual usage of each function implementation is    %
  % counted.  this allows later build optimizations which include only        %
  % generating functions that are used.                                       %
  %---------------------------------------------------------------------------%
  hRtwFcnLib = get_param(modelName,'TargetFcnLibHandle');
  % validate that Tfl and Hw are compatible
  TflStr = get_param(modelName, 'TargetFunctionLibrary');
  HwStr = get_param(modelName, 'TargetHWDeviceType');
  validateTflHw(hRtwFcnLib, TflStr, HwStr);

  slprivate('slbuild_profile', modelName, 'log', ...
            'tlc_c: reset function implementation counts', ...
            profileOn, mdlRefTgtType);
  
  % Validate TFL checksum; this check supports incremental build with top-model
  % PIL simulation; code for the top model must be regenerated if the TFL
  % checksum has changed
  if isfield(iMdlRefBuildArgs,'StoredTFLChecksum')
      storedTFLChecksum = iMdlRefBuildArgs.StoredTFLChecksum;
      if  ~isempty(storedTFLChecksum)
          temp_result = hRtwFcnLib.getIncrBuildNum();
          currentTflChecksum = [ temp_result.NUM1, ...
                              temp_result.NUM2, ...
                              temp_result.NUM3, ...
                              temp_result.NUM4 ];
          if all(storedTFLChecksum==currentTflChecksum)
              tflChecksumIsUpToDate = true;
          else
              % Invalidate other checksums forces rtwgen to generate code
              iMdlRefBuildArgs.StoredParameterChecksum = [];
              iMdlRefBuildArgs.StoredChecksum = [];
          end
      end
  end

  % Evaluate a checksum for any currently active build hooks
  if isfield(iMdlRefBuildArgs','BuildHooks')
      buildHooksChecksum = rtw.pil.BuildHook.getChecksum(...
          modelName, ...
          iMdlRefBuildArgs.BuildHooks, ...
          iMdlRefBuildArgs.TopOfBuildModel);
      % Validate the build hooks checksum; this checksum enforces a re-build if build
      % hook (e.g. code coverage) settings have changed
      if isfield(iMdlRefBuildArgs,'StoredBuildHooksChecksum')
          storedHookChecksum = iMdlRefBuildArgs.StoredBuildHooksChecksum;
          if  ~isempty(storedHookChecksum) && ~isempty(buildHooksChecksum)
              if ~all(storedHookChecksum==buildHooksChecksum)
                  % Invalidate other checksums forces rtwgen to generate code
                  iMdlRefBuildArgs.StoredParameterChecksum = [];
                  iMdlRefBuildArgs.StoredChecksum = [];
              end
          end
      end
  else
      buildHooksChecksum = [];
  end
          

  %---------------%
  % Invoke rtwgen %
  %---------------%
  try
    % Stash away pre-build dir for use with compile
    preBuildDir = pwd;

    slprivate('slbuild_profile', modelName, 'log', 'tlc_c: rtwgen start', ...
              profileOn, mdlRefTgtType);

    %
    % keep the RTWContext object until the code generation
    % from TLC is finished
    %
    set_param(modelName, 'RTWCGKeepContext', 'on');

    [sfcnsCell, buildInfo, modelrefInfo] = ...
        rtwgen(modelName, ...
               'PostponeTerm', 'off', ...
               'WriteDataRefs', 'on', ...
               'CaseSensitivity','on',...
               'Language', 'C', ...
               'OutputDirectory',buildDir, ...
               'MdlRefBuildArgs',iMdlRefBuildArgs);
    
    currentChecksum                = buildInfo{4};
    buildResult.codeWasUpToDate    = buildInfo{5};
    buildResult.runTimeParameters  = buildInfo{6};
    parameterChecksum              = buildInfo{7};
    parameterChecksumIsUpToDate    = buildInfo{8};
    
    targetType = iMdlRefBuildArgs.ModelReferenceTargetType;

    slprivate('slbuild_profile', modelName, 'log', 'tlc_c: rtwgen done', ...
              profileOn, mdlRefTgtType);

    % If iMdlRefBuildArgs.CheckCodeDonotRebuild is true or checksums are
    % the same, abort the build procedure. Otherwise, resave the binary file
    % and rebuild.

    stf = get_param(modelName,'SystemTargetFile');
    isRapidAccel = isequal(stf, 'raccel.tlc');
    if iMdlRefBuildArgs.CheckCodeDonotRebuild || buildResult.codeWasUpToDate

        if buildResult.codeWasUpToDate
            dh = dispOpts.DispHook;

            if strcmpi(targetType, 'NONE')
                raccelDispMsg = true;
                if (isRapidAccel)
                    try
                        raccelDispMsg = ...
                            (evalin('base', ...
                                    'rapidAcceleratorOptions.verbose') ...
                             ~= 0);
                    catch E %#ok
                        raccelDispMsg = false;
                    end
                end
                if raccelDispMsg
                    if (~parameterChecksumIsUpToDate) % i.e. it wasn't checked
                        msg = DAStudio.message( ...
                            'RTW:buildProcess:targetIsUpToDate', modelName);
                    else
                        assert(tflChecksumIsUpToDate && parameterChecksumIsUpToDate);
                        msg = DAStudio.message( ...
                            'RTW:buildProcess:targetIsUpToDate1', modelName);
                        
                    end
                    feval(dh{:},[sprintf('\n'), '### ', msg]);
                end
            else
                msg = DAStudio.message(...
                    'Simulink:modelReference:targetUpToDate', targetType, modelName);
                feval(dh{:},msg);
            end
        end
        set_param(modelName, 'RTWCGKeepContext', 'off');

        if(isfield(iMdlRefBuildArgs, 'forceCompile') &&...
           iMdlRefBuildArgs.forceCompile)
            forceCompile = true;
        elseif(isfield(iMdlRefBuildArgs, 'mdlRefsUpdated') &&...
           iMdlRefBuildArgs.mdlRefsUpdated)
            forceCompile = true;
        else
            forceCompile = false;
        end % if
        
        if((~iMdlRefBuildArgs.CheckCodeDonotRebuild) && forceCompile)
            % if this is a parallel build, we want to recompile the code in
            % the master anchor dir instead of the local build dir.  The
            % local build dir will not have any code in it because we detected
            % earlier that no code-gen was needed.
            
            % If rtwinfomatman has a parallel anchor dir set, then this is a
            % parallel build, and the value is the master anchor dir.
            mAnchorDir = rtwprivate('rtwinfomatman', 'getParallelAnchorDir',...
                                    h.MdlRefBuildArgs.ModelReferenceTargetType);
            if ~isempty(mAnchorDir)
                % the model reference build dir is in a subdir of the anchor dir
                % under slprj.  the gensettings has the correct subdir name to
                % use.
                [~, genSet] = rtwprivate('getSTFInfo',h.ModelName);
                if strcmp(iMdlRefBuildArgs.ModelReferenceTargetType,'SIM')
                    mdlRefBDir = genSet.mdlRefRelativeSimDir;
                else
                    mdlRefBDir = genSet.mdlRefRelativeBuildDir;
                end
                cd(fullfile(mAnchorDir, mdlRefBDir));
                anchorDir = mAnchorDir;
            else
                % this is a sequential build.  the local build dir is where the
                % code is.
                cd(buildDir);
            end
            % this will put buildInfo, buildOpts and templateMakefile into the
            % workspace
            load('buildInfo.mat');
            
            
            % For PIL simulation mode it is possible that the top model code is re-compiled
            % without being re-generated
            if strcmp(targetType,'NONE')
                targetTypeName = 'standalone';
            else
                targetTypeName = targetType;
            end
            
            msg = sprintf(['### Recompiling %s target for %s because a '...
                           'referenced model was recompiled.'], ...
                          targetTypeName, modelName);
            feval(dh{:}, msg);
        
            % For Windows, we need to clear the mex file before the build
            % because it might be locked.  
            targetext = '';
            switch(iMdlRefBuildArgs.ModelReferenceTargetType)
              case 'SIM'
                targetext = modelrefutil('', 'getBinExt', ...
                                         iMdlRefBuildArgs.protectedModelReferenceTarget);
                    
                case 'RTW'
                    targetext = '_sf';
            end % switch
            mexfile = [modelName, targetext];
            clear(mexfile);
            
            % Copy over the libraries
            infoStruct = rtwprivate('rtwinfomatman','load','binfo', ...
                                    h.ModelName,h.MdlRefBuildArgs.ModelReferenceTargetType);
            if((~buildOpts.useRelativePaths) &&...
               (~buildOpts.generateCodeOnly)) %#ok<NODEF>
                copy_libs_to_builddir(infoStruct.linkLibrariesFullPaths,...
                                      anchorDir)
            end % if

            if(isequal(get_param(modelName, 'GenerateMakefile'), 'on'))
                buildOpts.forceCompile = true;
                
                RTW.genMakefileAndBuild(buildInfo,...
                                        templateMakefile,...
                                        buildOpts);
            else
                % Back up the current build info
                origBuildInfo = h.BuildInfo;
                
                % Set it to the save one
                h.BuildInfo = buildInfo;
                
                % Run the Post Code Gen Hook
                PCGHook(h); 
                
                % Restore from the backup
                h.BuildInfo = origBuildInfo;
            end % if
        end % if
        
        DoTermRTWgen(modelName, preBuildDir);
        return;
    end

    % We are really generating code at this point, print
    % any status messages for SIM/RTW targets
    if iMdlRefBuildArgs.UseChecksum && ~strcmpi(targetType, 'NONE')
        msg1 = DAStudio.message('RTW:makertw:enterMdlRefTarget',...
                                mdlRefTgtType, modelName);
        msg2 = DAStudio.message('RTW:makertw:generatingCode', h.BuildDirectory);
        feval(dispOpts.DispHook{:}, msg1);
        feval(dispOpts.DispHook{:}, msg2);
    end
    
    if isRapidAccel
        % update display on the title/status bar
        statusMsg = DAStudio.message('Simulink:tools:rapidAccelBuilding');
        set_param(modelName, 'StatusString', statusMsg);
        % display a message in the command window
        msg = DAStudio.message('Simulink:tools:rapidAccelBuildStart', ...
                               modelName);
        feval(dispOpts.DispHook{:}, ['### ', msg]);
    end

    %
    % Initialize the RTWContext pointer in rtwcgtlc with the models
    % RTWContext object
    %
    rtwcgtlc('InitializeRTWContext', ...
             get_param(modelName, 'RTWCodeGenerationContext'));
    set_param(modelName, 'RTWCodeGenerationContext', []);
    set_param(modelName, 'RTWCGKeepContext', 'off');

    hRtwFcnLib = get_param(modelName,'TargetFcnLibHandle');


    buildResult.rtwFile   = [modelName,'.rtw'];
    buildResult.listSFcns = sfcnsCell;
    buildResult.modelrefInfo = modelrefInfo;

    % Get the current value of the tlcArgs, it may have been changed
    % during the call to rtwgen.
    cs = getActiveConfigSet(modelName);
    tlcArgs = cs.getStringRepresentation('tlc_options');

    %-----------------------------------------------------------%
    % Get S-functions info:                                     %
    %   sfcnsIncCell       - TLC include paths,                 %
    %   noninlinedSFcns    - noninlined S-functions and modules %
    %   haveStateflowSFcns - 0 or 1                             %
    %-----------------------------------------------------------%

    buildResult.noninlinedSFcns = buildInfo{1};
    buildResult.noninlinednonSFcns = {};
    % buildInfo{1} is a (unique) list of non-inlined S-function names and
    % any additional modules.  Migrate the "additional modules" from the
    % 'buildResult.noninlinedSFcns' to 'buildResult.noninlinednonSFcns'.  To do this,
    % scan for 'SfunctionModules' in the list of s-functions (buildResult.listSFcns)
    % that are exact matches of an entry in buildResult.noninlinedSFcns.

    for i=1:length(buildResult.listSFcns)
      % Only need to search for match in s-functions with 'SfunctionModules'
      if ~isempty(buildResult.listSFcns{i}{4})

          % first convert the string to a cell array of module names
        sfcnModCells = regexp(buildResult.listSFcns{i}{4},'(\w+)','tokens');
        sfcnMods = [sfcnModCells{:}];

        % get the names that match and move them to the non-inlined non
        % sfunction list.
        [~, nonSfcnIdx] = intersect(buildResult.noninlinedSFcns, sfcnMods);

        sfcnIdx = setdiff(1:length(buildResult.noninlinedSFcns),nonSfcnIdx);

        noninlinednonSFcns = buildResult.noninlinedSFcns(nonSfcnIdx);

        buildResult.noninlinednonSFcns =...
            [buildResult.noninlinednonSFcns(:); noninlinednonSFcns(:)]';
        buildResult.noninlinedSFcns    = buildResult.noninlinedSFcns(sfcnIdx);

      end
    end
    % done manipulating: buildResult.noninlinedSFcns, buildResult.noninlinednonSFcns

    sfcnsIncCell       = buildInfo{2};
    haveStateflowSFcns = buildInfo{3} > 0;  % numStateflowSFcns > 0

    rtwinfomatman('addChecksum','binfo',modelName,...
                  targetType, currentChecksum, parameterChecksum,...
                  buildHooksChecksum);

    % We do not need to compare
    % currentTflChecksum with the saved one, because if they are not matching
    % it must have been caught by SharedUtility errors.
    % By this point, the TFL tables must have been loaded
    % by rtwgen.
    temp_result = hRtwFcnLib.getIncrBuildNum();
    currentTflChecksum = [ temp_result.NUM1, ...
                           temp_result.NUM2, ...
                           temp_result.NUM3, ...
                           temp_result.NUM4 ];

    rtwinfomatman('addTflChecksum','binfo',modelName,...
                  targetType, currentTflChecksum);

    % Save info about s-functions, (such as the sfcn.m or sfcn.dll and sfcn.tlc and
    % any s-function modules that implement the s-function), to the minfo
    % matfile. We check the time stamp these files to check if we need to
    % rebuild the model reference or top-model target. Note that we skip
    % s-functions that live inside matlab/toolbox dir, because are a part of the
    % product that do not change, hence no point checking their time stamps.
    sfcnInfo = [];
    idx = 0;
    mlTbxDir = [matlabroot,filesep,'toolbox'];
    for i=1:length(sfcnsCell)
        sfcn = sfcnsCell{i}{2};
        sfcnFile = which(sfcn); % m or mex file that implements sfcn
        sfcnDir  = fileparts(sfcnFile);
        if (findstr(mlTbxDir,sfcnFile) == 1)
            continue;
        end
        % skip this sfcn if it is already in sfcnInfo
        if ~isempty(sfcnInfo)
            sfcns = {sfcnInfo(:).FunctionName};
            if ~isempty(strmatch(sfcn,sfcns,'exact'))
                continue;
            end
        end
        tlcDir  = '';
        modules = {};
        if sfcnsCell{i}{3} == 1 % => inlined
            tlcDir = sfcnsCell{i}{5};
            if isempty(tlcDir)
                tlcDir = '.';
            else
                tlcDir = strrep(tlcDir,sfcnDir,'<SFCNDIR>');
            end;
            % Add S-Function modules to sfcnFiles
            if ~isempty(sfcnsCell{i}{4})
                modules = ConvertDelimStrToCells(sfcnsCell{i}{4});
            end
        end
        idx = idx+1;
        sfcnInfo(idx).Block = getfullname(sfcnsCell{i}{1});  %#ok<AGROW>
        sfcnInfo(idx).FunctionName = sfcn;  %#ok<AGROW>
        sfcnInfo(idx).TLCDir       = tlcDir;  %#ok<AGROW>
        sfcnInfo(idx).Modules      = modules;  %#ok<AGROW>
    end
    rtwinfomatman('saveSfcnInfo', 'binfo', ...
                  modelName, targetType, sfcnInfo);

    %---------------------------------%
    % Cleanup the RTW build directory %
    %---------------------------------%
    CleanupBuildDir(buildDir, modelName)

    %---------------------------------------%
    % Cleanup the RTW HTML report directory %
    %---------------------------------------%
    reportInfoFileName = fullfile(buildDir,'html','reportInfo.mat');
    if exist(reportInfoFileName, 'file')       
        rtw_delete_file(reportInfoFileName);
    end
    
    %---------------------%
    % RTW before_tlc hook %
    %---------------------%
    callMakeHook(h,'before_tlc');

    %------------%
    % Invoke TLC %
    %------------%
    slprivate('slbuild_profile', modelName, 'log', 'tlc_c: TLC phase start', ...
              profileOn, mdlRefTgtType);
    mdlRefTargetType = iMdlRefBuildArgs.ModelReferenceTargetType;
    indentCmd = InvokeTLC(dispOpts, buildDir, modelName, rtwroot, ...
                          systemTargetFile, tlcArgs, sfcnsIncCell, ...
                          mdlRefTargetType,haveStateflowSFcns, ...
                          h.GeneratedTLCSubDir, profileOn,...
                          iMdlRefBuildArgs.protectedModelReferenceTarget);
    %
    % destroy the RTWContext object and reset its pointer in the rtwcgtlc file
    %
    rtwcgtlc('DestroyRTWContext');

    slprivate('slbuild_profile', modelName, 'log', 'tlc_c: TLC phase done', ...
              profileOn, mdlRefTgtType);

    %---------------------------------------------------------------------%
    % Add information into buildInfo for Stateflow aux dependencies
    %---------------------------------------------------------------------%
    sfprivate('auxInfoAddToBuildInfo', h, modelName, buildDir)
    
    %----------------------------------------------%
    % CD into build directory for indent and build %
    %----------------------------------------------%
    cd(buildDir);
    
    % ---------------------------------------------%
    % Run CodeInfo file
    % ---------------------------------------------%
    filePath = [buildDir, filesep, 'writeCodeInfoFcn'];
    if (exist([filePath, '.m'], 'file'))
        try
            eval(['run(''', filePath,''')']);
        catch codeInfoEx
            ciMsg = DAStudio.message('RTW:buildProcess:CodeInfoInternalError'); 
            ciExc = MException('RTW:buildProcess:CodeInfoInternalError',ciMsg);
            ciExc = ciExc.addCause(codeInfoEx);
            throw(ciExc);
        end
        deleteRTWFile = strcmp(get_param(bdroot,'RTWRetainRTWFile'),'off');
        if (deleteRTWFile)
            rtw_delete_file([filePath, '.m']);
        end
    end

    %-------------------------------------------------------------------------%
    %  For S-function/Accelerator targets, clear the mex file and del the obj %
    %-------------------------------------------------------------------------%
    ClearModelMexAndDeleteObject(modelName, codeFormat, mdlRefTargetType,...
                                 iMdlRefBuildArgs);
    
    %--------------------------------------------------------------------------%
    % Add information into buildInfo for those hit entries
    %--------------------------------------------------------------------------%
    AddTflUsageInfoToBuildInfo(h, modelName, hRtwFcnLib, mdlRefTargetType);
    
    %--------------------------------------------------------------------------%
    % Get modules to indent, build. This doesn't include target specific files %
    %--------------------------------------------------------------------------%
    [moduleList,moduleHeaderList,userList,userHeaderList] = ...
        GetModulesFromBuildDir(h,modelName, hRtwFcnLib);

    try
        eval([indentCmd, moduleList]);  % ignore indent errors
        eval([indentCmd, moduleHeaderList]);
    catch exc %#ok<NASGU>
    end
    % Make sure user files are compiled. Concatenate the two lists
    moduleList = [moduleList, ' ', userList];
    moduleHeaderList = [moduleHeaderList, ' ', userHeaderList]; %#ok<NASGU>
    
    %-------------------------%
    % Create return arguments %
    %-------------------------%

    % Create string list of all modules, including Simulink and Stateflow:
    buildResult.modules = GetBuildModuleList(h, ...
                                          haveStateflowSFcns,...
                                          moduleList,...
                                          sfcnsCell,...
                                          codeFormat,...
                                          mdlRefTargetType,...
                                          iMdlRefBuildArgs, ...
                                          hRtwFcnLib);
    DoTermRTWgen(modelName, preBuildDir);
  catch exc
    % Switch back to pre-build dir so that we can find all
    % S-functions and do their terminate
    DoTermRTWgen(modelName, preBuildDir);
    rethrow(exc);
  end
  slprivate('slbuild_profile', modelName, 'log', 'tlc_c: done', ...
            profileOn, mdlRefTgtType);



%endfunction tlc_c


%----------------------------------------------------------------------%
%                         Local functions                              %
%----------------------------------------------------------------------%

% Function: CleanupBuildDir ====================================================
% Abstract:
%   Delete generated files from a previous build.
%
%   It is assumed that all files were generated by this file
%   unless the file contains in the *first* line:
%      target specific file
%   For example:
%      /*  COMPANY-NAME target specific file
%       *
%       *    This file is created for use with the blah target. It
%       *    is used for ...
%       */
%      ...
%
function CleanupBuildDir(buildDir, modelName)
  cWd = pwd;
  cd(buildDir);

  % On PC, delete .pdb files if DEVSTUDIO_LOC specified.
  % DEVSTUDIO_LOC is an internal compiler definition location
  % the MathWorks uses for testing various versions of the
  % compilers. The .pdb files created by Visual C/C++ are
  % not compatible between different versions of Visual C/C++
  if ~isunix,
    makeCmd = get_param(modelName,'RTWMakeCommand');
    if (length(makeCmd) > 13) && ...
          ~isempty(findstr(makeCmd,'DEVSTUDIO_LOC=')) && ...
          ~isempty(dir('*.pdb'))
      dos('del *.pdb');
    end
  end

  % remove the referenced model header dir
  refMdlIncDir = fullfile(pwd,'referenced_model_includes');
  if (exist(refMdlIncDir,'dir') == 7)
      builtin('rmdir',refMdlIncDir,'s');
  end
  
  %
  % Delete any existing *.c and *.h files that are generated by
  % TLC.
  %
  DeleteBuildDirFiles('*.c')
  DeleteBuildDirFiles('*.cpp')
  DeleteBuildDirFiles('*.h')
  DeleteBuildDirFiles('*.txt')
  DeleteBuildDirFiles('*.a2l')
  
  %
  % Clean report directory
  %
  reportDir = fullfile(buildDir,'html');
  if exist(reportDir, 'dir')
      [s, w] = rmdir('html', 's');
      if ~s
          DAStudio.error('RTW:utility:removeError',w);
      end
  end
  
  %
  % For the ERT/GRT/GRT_Malloc target, delete any main function object files
  %
  if ispc,
    ext='.obj';
  else
    ext='.o';
  end
  mainObjFile = ['*rt*_main', ext];
  DeleteBuildDirFiles(mainObjFile);
  rtSimObjFile = ['rt_sim', ext];
  DeleteBuildDirFiles(rtSimObjFile);
  %  rtLogObjFile = ['rt_logging', ext];
  % DeleteBuildDirFiles(rtLogObjFile);
  
  clear('writeCodeInfoFcn')
  DeleteBuildDirFiles('writeCodeInfoFcn.m')
  DeleteBuildDirFiles('codeInfo.mat')

  cd(cWd);

% endfunction CleanupBuildDir


% Function: DeleteBuildDirFiles
% Abstract:
%     Delete specified files from the build directory
%
function DeleteBuildDirFiles(specifiedFiles)
  files = dir(specifiedFiles);

  for fileIdx = 1:length(files)
    deleteFile = true; % assume

    file = files(fileIdx).name;
    fid  = fopen(file,'rt');
    if fid == -1,
        DAStudio.error('RTW:utility:fileIOError',file,'open');
    end
    line = fgetl(fid);
    if ischar(line) && ~isempty(findstr('target specific file',line))
      deleteFile = false;
    end
    fclose(fid);

    if deleteFile
      rtw_delete_file(file);
    end
  end

% Function: IsSFcnOrAcceleratorOrModelrefSimTarget =======================
% Abstract:
%     Indicate if the code format is either of the following:
%             'S-Function'
%             'Accelerator_S-Function'
%             'Model reference sim' target
%
function isSFcnFmt = IsSFcnOrAcceleratorOrModelrefSimTarget(modelName, ...
                                                    codeFormat, mdlRefTargetType) %#ok
  isSFcnFmt    = ~isempty(findstr(codeFormat,'S-Function')) || ...
      strcmpi(mdlRefTargetType, 'SIM');

%endfunction IsSFcnOrAcceleratorOrModelrefSimTarget



% Function: GetTLCIncludePath ==================================================
% Abstract:
%    Setup and return include path for TLC
%
function incDir = GetTLCIncludePath(rtwroot, systemTargetFile,sfcnsIncCell, ...
                                    buildDir, generatedTLCSubDir, ...
                                    haveStateflowSFcns) %#ok
  incDir = {};

  k = findstr(systemTargetFile,filesep);
  if ~isempty(k)
    incDir{end+1} = ['-I', systemTargetFile(1:k(end)-1)];
  end
  for i=1:length(sfcnsIncCell)
    incDir{end+1} = ['-I' sfcnsIncCell{i}];  %#ok<AGROW>
  end
  scriptDir = buildDir;

  incDir{end+1} = ['-I' fullfile(buildDir,generatedTLCSubDir)];

  mlscriptDir = fullfile(scriptDir,'mlscript');

  if exist(mlscriptDir,'dir'),
    incDir{end+1} = ['-I', mlscriptDir];
  end

  incDir{end+1} = ['-I', fullfile(rtwroot, 'c', 'tlc','mw')];
  incDir{end+1} = ['-I', fullfile(rtwroot, 'c', 'tlc','lib')];
  incDir{end+1} = ['-I', fullfile(rtwroot, 'c', 'tlc','blocks')];
  incDir{end+1} = ['-I', fullfile(rtwroot, 'c', 'tlc','fixpt')];
  % vijay: due to eml and other considerations, add this directory
  % unconditionally
  incDir{end+1} = ['-I', fullfile(matlabroot, 'stateflow', 'c','tlc')];


%endfunction GetTLCIncludePath



% Function: GetTLCcmd ==========================================================
% Abstract:
%   Generate the tlc command used to generate code.
%
function tlcCmd = GetTLCcmd(buildDir, generatedTLCSubDir, modelName, ...
  systemTargetFile, tlcArgs, rtwroot, sfcnsIncCell, haveStateflowSFcns)

  %-----------------------------%
  % Create include path for TLC %
  %-----------------------------%
  incDir = GetTLCIncludePath(rtwroot, systemTargetFile, sfcnsIncCell, ...
                             buildDir, generatedTLCSubDir, haveStateflowSFcns);

  tlcCmd = {'tlc'};
  tlcCmd{end+1} = '-r';
  tlcCmd{end+1} = [buildDir,filesep,modelName, '.rtw'];
  tlcCmd{end+1} = systemTargetFile;
  tlcCmd{end+1} = ['-O',buildDir];

  tlcDebugOn = strcmp(get_param({modelName}, 'TLCDebug'), 'on');
  if tlcDebugOn,
      % Disable the Simulink Debugger when TLC debugger is active
    if isempty(sldebugui('GetHandle'))
        set_param(0,'SlDebugEnable','off');
        tlcCmd{end+1} = '-dc';
    else
        DAStudio.warning('Simulink:tools:NoTLCDebugWithSLDebug');
    end
 end

  tlcCoverageOn = strcmp(get_param({modelName}, 'TLCCoverage'), 'on');
  if tlcCoverageOn,
    tlcCmd{end+1} = '-dg';
  end

  tlcAssertionOn = strcmp(get_param({modelName}, 'TLCAssertion'), 'on');
  if tlcAssertionOn,
    tlcCmd{end+1} = '-da';
  end

  
  
  % The eval below is used to invoke MATLAB's quoting mechanism for command line
  % style invocation of functions, e.g. "f a" instead of "f('a')".  This quoting
  % mechanism does what we want here since it adds quotes if not already
  % present. It assumes tlcArgs is in MATLAB format, i.e. special characters
  % like ';' have been quoted.  For example,
  %
  %     CurlyBracketOperator '-aFoo="x y"' -aGoo=1
  %
  % returns {'-aFoo="x y"', '-aGoo=1'}.

  eval(['CurlyBracketOperator set ' tlcArgs ';']);

  tlcArgsAsCellArray = CurlyBracketOperator('get');
  
  tlcCmd = [tlcCmd, incDir, tlcArgsAsCellArray];

% endfunction GetTLCcmd

%endfunction: ConfigForTLC


function y = CurlyBracketOperator(action, varargin)
  persistent tmp;
  if strcmp(action,'set');
    tmp = varargin;
    y = [];
    return;
  end
  % we are 'get' ing the list, clear out the persistent var
  y = tmp;
  tmp = [];

% Function: InvokeTLC ==========================================================
% Abstract:
%   Invoke TLC to generate the *.c, *.h files.
%   This will also do TLC profiling if requested.
%   This is also the funnel for TLC coverage logging.
%
function indentCmd = InvokeTLC(dispOpts, buildDir, modelName, rtwroot, ...
                               systemTargetFile, tlcArgs, sfcnsIncCell, ...
                               mdlRefTargetType,haveStateflowSFcns, ...
                               generatedTLCSubDir, compilerStatsOn, ...
                               protectedModelReferenceTarget)
  dh = dispOpts.DispHook;
  if dispOpts.rtwVerbose
    feval(dh{:},['### Invoking Target Language Compiler on ',modelName,'.rtw']);
  end

  %---------------------%
  % Build TLC arguments %
  %---------------------%
  tlcCmd = GetTLCcmd(buildDir, generatedTLCSubDir, modelName, ...
                     systemTargetFile, tlcArgs, rtwroot, sfcnsIncCell, ...
                     haveStateflowSFcns);

  % -p0 is special to mean "turn it off". Specifically useful for demos

  if compilerStatsOn
      tlcCmd{end+1} = '-aTLCCompileStats=1';
      tlcCmd{end+1} = sprintf('-aTLCCSTargetType="%s"', mdlRefTargetType);
  end
  
  tlcCmd{end+1} = sprintf('-aProtectedModelReferenceTarget=%d',...
                          protectedModelReferenceTarget);
  
  tlcCmd = strrep(tlcCmd,'-p0','-p10000000');

  if dispOpts.rtwVerbose,
    if isempty(strmatch('-p',tlcCmd)),
      tlcCmd{end+1} = '-p10000';
    end
    feval(dh{:},['### Using System Target File: ',systemTargetFile]);
  end

  if ~isunix,
    bufstate = cmd_window_buffering('off');
  end

  tlcProfilerOn = strcmp(get_param({modelName}, 'TLCProfiler'), 'on');
  if tlcProfilerOn,
    %
    % TLC Profiling
    %
    htmlFile = [modelName,'.html'];
    htmlFile = [buildDir, filesep, htmlFile];
    feval(dh{:},['### Generating TLC profile: ', htmlFile]);
  end

  %
  % See if we should force TLC coverage to be on
  %
  try
      tlcLogsSaveDir = evalin('base', 'rtw_mathworks_tlc_logs_dir__');
  catch exc %#ok<NASGU>
      tlcLogsSaveDir = '';
  end
  if ~isempty(tlcLogsSaveDir)
      tlcCmd = strrep(tlcCmd,'-aGenerateReport=1','-aGenerateReport=0');
      tlcCmd{end+1} = '-dg';
  end

  indentCmd = rtwprivate('rtwattic', 'beautifierCmd', modelName);

  if ~isempty(strmatch('-aGenerateComments=0',tlcCmd))
      indentCmd = [indentCmd '-nocomments '];
  end

  if rtwprivate('checkForTLCShadowVariable')
      tlcCmd{end+1} = '-shadow1';
  end

  SaveTlcCommand(tlcCmd, modelName, buildDir);

  action = 'ProvideTLCService';
  callTLCService(action, tlcCmd, tlcProfilerOn, buildDir, ...
                 modelName, tlcLogsSaveDir);

  if ~isempty(strmatch('-aCompactFilePackaging=1',tlcCmd))
    rtw_delete_file(fullfile(buildDir,[modelName,'_prm.h']));
    rtw_delete_file(fullfile(buildDir,[modelName,'_reg.h']));
    rtw_delete_file(fullfile(buildDir,[modelName,'_common.h']));
    rtw_delete_file(fullfile(buildDir,[modelName,'_export.h']));
  end


  if ~isunix,
    cmd_window_buffering(bufstate);
  end

  set_param(0,'SlDebugEnable','on');
% endfunction InvokeTLC


% Function: SaveTlcCommand ===================================================
% Abstract:
%   If the .rtw file will be saved, also save the tlc command and a script that
%   can be used to re-invoke it.
%
function SaveTlcCommand(tlccmd, iModelName, iBuildDir)

  deleteRTWFile = strcmp(get_param(iModelName,'RTWRetainRTWFile'),'off');
  if ~deleteRTWFile
    funcname = 'runtlccmd';
    matFileName = fullfile(iBuildDir, 'tlccmd.mat');
    mFileName = fullfile(iBuildDir, [funcname '.m']);
    makertwObj = get_param(iModelName,'MakeRTWSettingsObject');  %#ok<NASGU>
    save(matFileName, 'tlccmd','makertwObj');
    fcntext = GetFcn(funcname, iModelName, iBuildDir, tlccmd);
    WriteLinesToFile(mFileName, fcntext);
  end

function f = GetFcn(iFuncName, iModelName, iBuildDir, iTlcCmd)
  c = GetComment(iFuncName, iModelName, iTlcCmd);
  f = [...
      {['function ' iFuncName]}, ...
      c,...
      {''}, ...
      {'   disp(''This function will be obsoleted in a future release.'') '}, ...
      {['   mdl = ''' iModelName ''';']}, ...
      {''}, ...
      {['   sysopen = ~isempty(strmatch(mdl, find_system(''type'', '...
       '''block_diagram''), ''exact''));']}, ...
      {''}, ...
      {'   if ~sysopen'}, ...
      {''}, ...
      {['      disp([mfilename '': Error: model '' mdl '' is not open. '...
       'Please open model '' mdl '' and then run '' mfilename '' again'...
       '.'']);']}, ...
      {''}, ...
      {'   else'}, ...
      {''}, ...
      {['      rtwprivate(''rtwattic'', ''setBuildDir'', ''' iBuildDir ''');']}, ...
      {['      rtwprivate(''ec_set_replacement_flag'', ''' iModelName ''');']}, ...
      {'      load tlccmd.mat;'}, ...
      {'      savedpwd = pwd;'}, ...
      {'      cd ..;'}, ...
      {'      set_param(mdl,''MakeRTWSettingsObject'', makertwObj);'}, ...
      {'      feval(tlccmd{:});'}, ...
      {'      set_param(mdl,''MakeRTWSettingsObject'', []);'}, ...
      {'      rtwprivate rtwattic clean;'}, ...
      {'      cd(savedpwd);'}, ...
      {''}, ...
      {'   end'} ...
      ];
  
  f = sprintf('%s\n',f{:});

function c = GetComment(iFuncName, iModelName, iTlcCmd)
  c = strcat({sprintf('\t')}, iTlcCmd);
  c = [...
      {[upper(iFuncName) ' - run tlc command (regenerate C code from .rtw '...
       'file) for model ' iModelName]}, ...
      {'This function will run the tlc command stored in the variable '}, ...
      {'"tlccmd" in tlccmd.mat, whose contents is as follows:'}, ...
      {''},...
      c ...
      ];
  c = strcat({'% '}, c);


function WriteLinesToFile(iFileName, iLines)
  [fid errmsg] = fopen(iFileName, 'wt');
  if ~isempty(errmsg)
      DAStudio.error('RTW:utility:fileIOError',iFileName,'open');
  end

  fprintf(fid,'%s', iLines);

  fcloseStatus = fclose(fid);
  if fcloseStatus ~= 0
      DAStudio.error('RTW:utility:fileIOError',iFileName,'close');
  end


% Function: GetBaseModelFile ===================================================
% Abstract:
%   Return the base model file name.
%   Normally this is the name of the model except
%     - for the S-function target it is model_sf
%     - for the Accelerator target it is model_acc
%
function baseModelFile = GetBaseModelFile(modelName, codeFormat, mdlRefTargetType,...
                                          mdlRefBuildArgs)

  switch codeFormat
   case 'S-Function'
    baseModelFile = [modelName,'_sf'];
   case 'Accelerator_S-Function'
    baseModelFile = [modelName,'_acc'];
   otherwise
    if strcmpi(mdlRefTargetType, 'SIM')
      ext = modelrefutil(modelName, 'getBinExt', mdlRefBuildArgs.protectedModelReferenceTarget);
      baseModelFile = [modelName,ext];
    elseif strcmpi(mdlRefTargetType, 'RTW')
      baseModelFile = '';
    else
      baseModelFile = modelName;
    end
  end

%endfunction GetBaseModelFile



% Function: ClearModelMexAndDeleteObject =======================================
% Abstract:
%   For accelerator, S-function target, we need to clear the MEX-file
%   prior to continuing with the build process.
%
function ClearModelMexAndDeleteObject(modelName, codeFormat,mdlRefTargetType, mdlRefBuildArgs)

  if IsSFcnOrAcceleratorOrModelrefSimTarget(modelName,codeFormat,mdlRefTargetType)

    mexfile = GetBaseModelFile(modelName, codeFormat, mdlRefTargetType, mdlRefBuildArgs);
    clear(mexfile);

    try
      if ispc,
        ext='.obj';
      else
        ext='.o';
      end
      objFile = [mexfile, ext];
      if exist(objFile,'file'),
        rtw_delete_file(objFile);
      end
    catch exc %#ok<NASGU>
    end
  end

%endfunction ClearModelMexAndDeleteObject



% Function: GetModulesFromBuildDir =============================================
% Abstract:
%   Read the build directory for .c and .h files to be indented, etc.
%
function [moduleList, moduleHeaderList, userList, userHeaderList] = ...
    GetModulesFromBuildDir(h,modelName,hRtwFcnLib)

  % as the code is inserted into the BuildInfo object, it will get one of
  % these group labels.
  buildDirGroup       = 'BuildDir';
  targetSpecificGroup = 'TargetSpecificFile';
  legacyGroup         = 'Legacy';

  % add the build dir and parent (which is stored in the startDirToRestore
  % parameter) to the source and include paths in the BuildInfo object
  standardDirs = h.BuildDirectory;
  standardGroups = buildDirGroup;
  h.BuildInfo.addSourcePaths(standardDirs,standardGroups);
  h.BuildInfo.addIncludePaths(standardDirs,standardGroups);

  % this will add the startdir to the include and source paths as well
  h.BuildInfo.setStartDir(h.StartDirToRestore);
  
  % the parallel anchor dir needs to be set in BuildInfo as well, if this is a
  % parallel build.
  mAnchorDir = rtwprivate('rtwinfomatman', 'getParallelAnchorDir',...
                          h.MdlRefBuildArgs.ModelReferenceTargetType);
  if ~isempty(mAnchorDir)
      h.BuildInfo.setMasterAnchorDir(mAnchorDir);
  end
  
  %
  % source list
  %

  moduleList = '';
  userList = '';
  src_files = {};
  src_files_group = {};
  user_files = hRtwFcnLib.getFilesCopiedToBldDir;
  if rtw_is_cpp_build(modelName)
      langExt = 'cpp';
  else
      langExt = 'c';
  end

  cfiles = dir('*.c');
  cppfiles = dir('*.cpp');
  cfiles = [cfiles; cppfiles];

  for fileIdx = 1:length(cfiles)
    addFile = true; % assume

    file = cfiles(fileIdx).name;
    % put this file in the vector for the BuildInfo object insertion
    src_files{fileIdx} = file; %#ok

    fid  = fopen(file,'rt');
    if fid == -1,
        DAStudio.error('RTW:utility:fileIOError',file,'open');
    end
    line = fgetl(fid);
    fclose(fid);
    % If the file is target specific, it gets a target specific group,
    % otherwise it gets the default build dir group.
    if ischar(line) && ~isempty(findstr('target specific file',line))
      addFile = false;
      src_files_group{fileIdx} = targetSpecificGroup; %#ok
    else
      src_files_group{fileIdx} = buildDirGroup; %#ok
    end

    % When makefile does not support ModelReference(i.e. old style) , it
    % will explicitly list rt_nonfinite.c in makefile. As such, do not
    % add to MODULES.
    if strcmp(file,['rt_nonfinite.' langExt])
      tmfVersion = get_tmf_version(modelName);
      if strcmp(tmfVersion,'Standalone')
        addFile = false;
        % note that this file is still added to the BuildInfo object even
        % though it is not listed in the moduleList.
        src_files_group{fileIdx} = legacyGroup; %#ok
      end
    end
    
    if strcmp(file,['grt_main.' langExt])
       addFile = false;
       src_files_group{fileIdx} = legacyGroup; %#ok
    end
    
    if ~isempty(user_files) && ...
       ismember(file, user_files)
      % Do not user files that are copied into the build directory
      % to be indented by the code beautifier
      addFile = false;
      userList = [userList, file,' ']; %#ok
    end
    
    if addFile
      moduleList = [moduleList, file,' ']; %#ok
    end
  end

  if ~isempty(moduleList)
    moduleList(end) = []; % delete trailing white space
  end
  
  if ~isempty(userList)
    userList(end) = []; % delete trailing white space
  end

  % add all of the source files to the BuildInfo object even if they are "target
  % specific" or rt_nonfinite.<langExt>.  However, first we must split the
  % include and source files.  Some files such as model_pt.c and model_bio.c are
  % actually include files.
  src_paths(1:length(src_files)) = {h.BuildDirectory};
  [inc, src] = locSplitIncAndSrcFiles(modelName,...
                                      langExt,...
                                      src_files,...
                                      src_paths,...
                                      src_files_group);
  
  % put all of the collected information into the BuildInfo object.
  h.BuildInfo.addSourceFiles(src.Files,src.Paths, src.Groups);
  if ~isempty(inc.Files)
      h.BuildInfo.addIncludeFiles(inc.Files,inc.Paths, inc.Groups);
  end

  %
  % Header list
  %

  moduleHeaderList = '';
  userHeaderList = '';
  inc_files = {};
  inc_files_group = {};

  hfiles = dir('*.h');
  for fileIdx = 1:length(hfiles)
    addFile = true; % assume

    file = hfiles(fileIdx).name;
    % put this file in the vector for the Buildinfo object insertion
    inc_files{fileIdx} = file; %#ok

    fid  = fopen(file,'rt');
    if fid == -1,
        DAStudio.error('RTW:utility:fileIOError',file,'open');
     end
    line = fgetl(fid);
    fclose(fid);
    % If the file is target specific, it gets a target specific group,
    % otherwise it gets the default build dir group.
    if ischar(line) && ~isempty(findstr('target specific file',line))
      addFile = false;
      inc_files_group{fileIdx} = targetSpecificGroup; %#ok
    else
      inc_files_group{fileIdx} = buildDirGroup; %#ok
    end

    if ~isempty(user_files) && ...
       ismember(file, user_files)
      % Do not user files that are copied into the build directory
      % to be indented by the code beautifier
      addFile = false;
      userHeaderList = [userHeaderList, file,' ']; %#ok
    end

    if addFile
      moduleHeaderList = [moduleHeaderList, file,' ']; %#ok
    end
  end

  % add all of the header files to the BuildInfo object even if they are
  % "target specific"
  h.BuildInfo.addIncludeFiles(inc_files,h.BuildDirectory, inc_files_group);

  if ~isempty(moduleHeaderList)
    moduleHeaderList(end) = []; % delete trailing white space
  end
  
  if ~isempty(userHeaderList)
    userHeaderList(end) = []; % delete trailing white space
  end

%endfunction GetModulesFromBuildDir

% Function: AddTflUsageInfoToBuildInfo =============================================
% Abstract:
%     Add modules associated with Tfl entries that have greater-than-zero
%     usage count into buildInfo.
%
function AddTflUsageInfoToBuildInfo(h, modelName, hRtwFcnLib, mdlRefTargetType)
    % Get TFL hit src, hdr and linkObj information from TflController.
    srcs = hRtwFcnLib.getUsedSourceFiles;
    hdrs = [hRtwFcnLib.getUsedHeaders; hRtwFcnLib.getSharedHeaders];
    hdrs = regexprep(hdrs, '<.+>', ''); % remove system headers from this list
    hdrs = regexprep(hdrs, '"', ''); % remove quotes from this list
    objs = hRtwFcnLib.getUsedLinkObjs;
	
    srcPaths  = RTW.expandToken(hRtwFcnLib.getUncopiedUsedSourcePaths);
    hdrPaths  = RTW.expandToken(hRtwFcnLib.getUncopiedUsedIncludePaths);
    objPaths  = RTW.expandToken(hRtwFcnLib.getUsedLinkObjsPaths);
    linkFlags = RTW.expandToken(hRtwFcnLib.getUsedLinkFlags);
    
    % Add TFL hit src, hdr and linkObj information to BuildInfo.
    
    % If shared location is specified, src files are to be in the
    % rtwshared.lib(a) group later.
    % Src files need to be added only if they are not going to shared location
    % Check if the model is a referenced model or is a top level model, as even
    % though UtilityFuncGeneration might be set to 'Auto' it will still
    % generate files in shared location
    cs = getActiveConfigSet(modelName);
    if ~(strcmp(mdlRefTargetType, 'RTW') || ...
            strcmp(get_param(cs, 'UtilityFuncGeneration'), 'Shared location'))
        
        mdlBlks = slInternal('findMdlRefsAndLibLinks',modelName);
        if isempty(mdlBlks)
            h.BuildInfo.addSourceFiles(srcs,'','TFL');
            % Add Tfl related Hdr files
            h.BuildInfo.addIncludeFiles(hdrs,'','TFL');
        end
    end
    
    % Add Tfl related LinkObj files in pair
    % Treat TFL entries specified LinkObjs as prebuild libs and link-only. According to
    % BuildInfo API, objs and objPaths must have the same dimension as one-to-one.
    h.BuildInfo.addLinkObjects(objs, objPaths, '', true, true, 'TFL');
    h.BuildInfo.addSourcePaths(srcPaths, 'TFL');
    h.BuildInfo.addIncludePaths(hdrPaths, 'TFL');
    h.BuildInfo.addLinkFlags(linkFlags);

%endfunction AddTflUsageInfoToBuildInfo

% Function: ConvertDelimStrToCells =============================================
% Abstract:
%     Converts a white-space delimited string to a row cell array
%     of individual strings.
%
function cellList=ConvertDelimStrToCells(strList)

  [s,f]=regexp(strList,'\S+');
  cellList = {};
  for i=1:length(s)
    cellList{i} = strList(s(i):f(i)); %#ok
  end

%endfunction ConvertDelimStrToCells



% Function: ConvertCellsToDelimStr =============================================
% Abstract:
%    Convert a cell array of strings to one space-delimited string.
%    Note that one delimiter will also be appended to the end of
%    the string being returned.
%
function str = ConvertCellsToDelimStr(cellStr)

  cellStr=cellStr(:);  % force into a column vector of strings

  % Construct cell array of delimiters (spaces),
  % to be appended to the end of each string in cellStr
  spaces={' '};
  spaces=spaces(ones(size(cellStr)));

  % Interleave delimiters with strings, and concatenate into one string
  cellStr = [cellStr spaces]';
  str = [cellStr{:}];

  % Force result to be an empty string, and not an empty array,
  % if no inputs.  This silences warnings from functions such
  % as strrep, which prefer '' on input, and not [].
  if isempty(str), str=''; end

%endfunction ConvertCellsToDelimStr

% Function: GetBuildModuleList =================================================
% Abstract:
%   Get the module list, which excludes the 'main module' (model.c, model_sf.c,
%   or model_acc.c).
%
function buildModuleList = GetBuildModuleList(h, ~,...
                                              moduleList, sfcnsCell, codeFormat, ...
                                              mdlRefTargetType, mdlRefBuildArgs, hRtwFcnLib) 
  modelName = h.ModelName;
  buildModuleList = moduleList; % .c files in the build directory excluding
                                % explicitly marked 'target specific file'
                                % files.

  % all insertions to the BuildInfo object will use one of the following
  % labels, depending on where the file/path originated from.
  sfcnGroup       = 'Sfcn';
  modelSrcsGroup  = 'ModelSources';
  customCodeGroup = 'CustomCode';

  % these vectors are filled in stages below, then inserted into the
  %  buildInfo object in one shot at the end
  depSrcFiles       = {};
  depSrcFilesPaths  = {};
  depSrcFilesGroups = {};

  % Add in an sources explicitly specified via the
  %   LibAddToModelSources() and SLibAddToStaticSources()
  % TLC function.

  fid = fopen('modelsources.txt','rt');
  if fid == -1,
      DAStudio.error('RTW:utility:fileIOError','modelsources.txt','open');
   end
  sources = fgetl(fid);
  if ischar(sources) && ~isempty(sources)
    buildModuleList = [buildModuleList, ' ',sources];
  end
  fclose(fid);

  %
  % Convert the string list to a cell list
  %
  buildModuleCell = ConvertDelimStrToCells(buildModuleList);

  % Add modules from existing BuildInfo source files that were added to the
  % BlockModules group.
  list = getSourceFiles(h.BuildInfo, false, false, 'BlockModules');
  buildModuleCell = [buildModuleCell list{:}];
  
  % we need to uniquify the list here because the sources from
  % modelsources.txt contain some files in the build dir (which are also in
  % moduleList passed in.
  buildModuleCell = RTW.unique(buildModuleCell);

  %collect the info on these modules for the DependencyTable
  numDepSrcFiles = length(buildModuleCell);
  depSrcFiles = [depSrcFiles buildModuleCell{:}];
  depSrcFilesPaths(1:numDepSrcFiles) = {''};
  depSrcFilesGroups(1:numDepSrcFiles) = {modelSrcsGroup};

  %
  % Add in Accelerator/S-Function target modules (required for build)
  %
  if IsSFcnOrAcceleratorOrModelrefSimTarget(modelName,codeFormat, mdlRefTargetType),
    for i = 1:length(sfcnsCell)
      if (sfcnsCell{i}{3} == 1)
        % The {i}{3}'th entry is 1 if the S-function is inlined.
        % The {i}{4}'th entry is a whitespace-delimited string
        % containing one or more names of code modules which are
        % required during compilation.
        moduleStr   = sfcnsCell{i}{4};
        sfcnPaths = {};
        sfcnGrps = {};
        if ~isempty(moduleStr)
          sfcnModules = ConvertDelimStrToCells(moduleStr);
          sfcnModules = Add_C_ExtToNames(sfcnModules);
          buildModuleCell = [buildModuleCell sfcnModules]; %#ok<AGROW>
          %collect the info on these modules for the DependencyTable
          nSfcnMods = length(sfcnModules);
          sfcnPaths(1:nSfcnMods) = {''};
          sfcnGrps(1:nSfcnMods) = {sfcnGroup};
          depSrcFiles = [depSrcFiles sfcnModules{:}]; %#ok<AGROW>
          depSrcFilesPaths = [depSrcFilesPaths  sfcnPaths]; %#ok
          depSrcFilesGroups = [depSrcFilesGroups sfcnGrps]; %#ok
        end
      end
    end
  end
  
  % Add in TFL source files that are not copied to the build directory
  % to the list of modules
  tflSrcs = hRtwFcnLib.getUncopiedUsedSourceFiles;
  if ~isempty(tflSrcs)
      buildModuleCell = [buildModuleCell tflSrcs{:}];
  end

  % Get custom code settings from configset
  cs          = getActiveConfigSet(modelName);
  rtwSettings = cs.getComponent('any', 'Real-Time Workshop');

  % Parse custom code settings in an effort to resolve file names
  custCodeFiles   = rtw_resolve_custom_code(h, rtwSettings.CustomInclude, ...
                                            rtwSettings.CustomSource, ...
                                            rtwSettings.CustomLibrary);
  buildModuleCell = [buildModuleCell custCodeFiles.parsedSrcFileNames];

  % the path lists contains the build dir, and the start dir, but the
  % BuildInfo insertion code will strip them out since they are already
  % in the object.
  h.BuildInfo.addIncludePaths(custCodeFiles.parsedIncludePaths,...
                              customCodeGroup);
  h.BuildInfo.addSourcePaths(custCodeFiles.parsedSrcPaths, customCodeGroup);

  % this is used for breaking out the path and filename components of a
  % fully qualified path.  The advantage to using this over fileparts
  % here is that it will operate on a cell array of strings, which is
  % much more efficient than a for loop.
  %
  % this regexp: (.*?%) [\\/]? grabs the path
  % this regexp: .*?[\\/]?([^\\/]*) grabs the file name with extension
  pathRegexp = '(.*?)[\\/]?[^\\/]*$';
  fileRegexp = '.*?[\\/]?([^\\/]*)$';

  if ~isempty(custCodeFiles.parsedSrcFiles)
      % first get the paths
      [~,tok] = regexp(custCodeFiles.parsedSrcFiles, pathRegexp,...
                        'match','tokens');
      tmp = [tok{:}];
      custCodeFilesPaths = [tmp{:}];

      % next get the filenames
      [~,tok] = regexp(custCodeFiles.parsedSrcFiles, fileRegexp,...
                        'match','tokens');
      tmp = [tok{:}];
      custCodeFileNames = [tmp{:}];

      % we also need the groups for these files
      custCodeFilesGroups(1:length(custCodeFileNames)) = {customCodeGroup};

      depSrcFiles       = [depSrcFiles custCodeFileNames];
      depSrcFilesPaths  = [depSrcFilesPaths custCodeFilesPaths];
      depSrcFilesGroups = [depSrcFilesGroups custCodeFilesGroups];
  end

  % get all the custom libraries in a similar manner as the custom code files
  if ~isempty(custCodeFiles.parsedLibFiles)
      % first get the paths
      [~,tok] = regexp(custCodeFiles.parsedLibFiles, pathRegexp,...
                        'match','tokens');
      tmp = [tok{:}];
      depLibsPaths = [tmp{:}];

      % next get the filenames
      [~,tok] = regexp(custCodeFiles.parsedLibFiles, fileRegexp,...
                        'match','tokens');
      tmp = [tok{:}];
      depLibs = [tmp{:}];

      % now add them to the BuildInfo object as link-only objects
      h.BuildInfo.addLibraries(depLibs,depLibsPaths,1000,...
                               false,true,customCodeGroup);
  end

  %
  % Build a unique list of sources. We will have duplicates because
  % modelsources.txt lists .c files found in the build directory (plus
  % other .c files, e.g. files in simulink/src for sb2sl).
  %
  buildModuleCell = RTW.unique(buildModuleCell);

  %
  % Remove .c(pp) files that are not considered modules:
  %  - Remove main module (model.c(pp)) because it is explicitly specified
  %    in the .tmf file.
  %  - Remove the model_pt.c(pp) and model_bio.c(pp) files because they are
  %    really include files.
  %  - Remove the model_sf.c(pp) because this is for the ert S-function
  %    format and is explicitly specified in the .tmf file.
  %
  if rtw_is_cpp_build(modelName)
      langExt = 'cpp';
  else
      langExt = 'c';
  end

  baseFileName = GetBaseModelFile(modelName,codeFormat, mdlRefTargetType, mdlRefBuildArgs);
  ignoreBaseMods = {};
  if ~isempty(baseFileName)
    ignoreBaseMods = {[baseFileName, '.', langExt]};
  end

  ignoreIncMods = {[modelName,'_pt.', langExt],...
                   [modelName,'_bio.', langExt]};

  ignoreEmbCMods = {};
  if strcmp(codeFormat,'Embedded-C')
    ignoreEmbCMods = {[modelName,'_sf.', langExt],...
                      ['ert_main.', langExt]};
  end

  ignoreModules = [ignoreBaseMods ignoreIncMods ignoreEmbCMods];
  
  
  buildModuleCell = setdiff(buildModuleCell,ignoreModules);

  %
  % Convert the buildModuleCell back to a buildModuleList string.
  %
  buildModuleList = ConvertCellsToDelimStr(buildModuleCell);

  [inc, src] = locSplitIncAndSrcFiles(modelName,...
                                      langExt,...
                                      depSrcFiles,...
                                      depSrcFilesPaths,...
                                      depSrcFilesGroups);
  
  %put all of the collected information into the BuildInfo object.
  h.BuildInfo.addSourceFiles(src.Files,src.Paths, src.Groups);
  if ~isempty(inc.Files)
      h.BuildInfo.addIncludeFiles(inc.Files,inc.Paths, inc.Groups);
  end

%endfunction GetBuildModuleList

% Function: DoTermRTWgen =======================================================
% Abstract:
%   Terminate rtwgen
%
function DoTermRTWgen(modelName, preBuildDir)
  % Switch back to pre-build dir so that we can find all
  % S-functions and do their terminate
  rtDir = cd(preBuildDir);
  rtwgen(modelName, 'TerminateCompile', 'on');
  if strcmp(get_param(modelName, 'RTWCGKeepContext'), 'on')
    set_param(modelName, 'RTWCGKeepContext', 'off');
    rtwcgtlc('ResetRTWContext');
  else
    set_param(modelName, 'RTWCodeGenerationContext', []);
    rtwcgtlc('DestroyRTWContext');
  end
  cd(rtDir);
%endfunction DoTermRTWgen


% Function: locSplitIncAndSrcFiles =============================================
%
function [inc, src] = locSplitIncAndSrcFiles(modelName, langExt,...
                                             inFiles, inPaths, inGroups)

  incMods = {[modelName,'_pt.', langExt],...
             [modelName,'_bio.', langExt]};


  % separate the include files from the sources
  [inc.Files,incIdx] = intersect(inFiles,incMods);
  inc.Paths          = inPaths(incIdx);
  inc.Groups         = inGroups(incIdx);
  
  [src.Files,srcIdx] = setdiff(inFiles,incMods);
  src.Paths          = inPaths(srcIdx);
  src.Groups         = inGroups(srcIdx);
 

% [EOF] tlc_c.m

% LocalWords:  noninlinednon TFL Tfl checksums Donot resave raccel
% LocalWords:  rtwinfomatman subdir slprj gensettings STF rtwcgtlc sfcns
% LocalWords:  Sfunction sfunction matfile SFCNDIR binfo del pdb DEVSTUDIO
% LocalWords:  Modelref mlscript mw vijay Ccmd da MATLAB's ing TLCCS rtwattic
% LocalWords:  nocomments runtlccmd tlccmd sysopen ec savedpwd acc startdir
% LocalWords:  nonfinite lang Buildinfo hdr Func rtwshared Objs prebuild objs
% LocalWords:  Delim SLib modelsources th whitespace sb tmf Wgen
