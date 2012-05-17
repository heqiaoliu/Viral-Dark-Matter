function buildResult = make_rtw(h, varargin) 
% MAKE_RTW is the main method of RTW.makertw class. It executes same
% functionality as original make_rtw function.

%   Copyright 2002-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.55 $  $Date: 2010/04/21 21:36:59 $

  buildResult = [];
  % check directory
  CheckDir(h);

  % Parse the build arguments %
  ParseBuildArgs(h, varargin);

  % Initialize the name of the current config set.
  modelName = h.ModelName;
  cs = getActiveConfigSet(modelName);
  
  % Assume that the RTW code is not up-to-date
  set_param(modelName, 'RTWCodeWasUptodate', 'off');
  
  % Cache original data
  CacheOriginalData(h);

  % prepare for accelerator mode and s-function generation
  PrepareAcceleratorAndSFunction(h);
  
  clearBuildInProgress = ~Simulink.fileGenControl('setBuildInProgress');
  
  %
  % All the build procedure is wrapped in a try .. catch so that if any errors
  % occur in this function or in any of the other functions called from here,
  % they all fall through to the catch, where we restore the cached lock and
  % dirty flags and re-echo the error that occurred during try.
  %
  try
    anchorDir = pwd;
    isMdlRefSim = strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType,'SIM');
    if isMdlRefSim
      setup_config_set_for_model_reference(h, true);  
      cs = getActiveConfigSet(modelName);
    end
    
    % Make sure model reference SIM is using modelrefsim.tlc
    if strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType,'SIM')
      tmpTg = cs.getProp('SystemTargetFile');
      if ~strcmp(cs.getProp('SystemTargetFile'), 'modelrefsim.tlc')
        assertMsg = ['Internal error: Model reference sim target ', ...
                     '(modelrefsim.tlc != ',tmpTg]; 
        assert(false,assertMsg);
      end
    end

    set_param(modelName, 'MakeRTWSettingsObject',h);

    % Get the system target file
    GetSystemTargetFile(h);

    inbat = rtwprivate('rtwinbat');
    notMdlRef = strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType,'NONE');

    % Call user defined RTW hook entry method, and issue start build message by
    % default
    callMakeHook(h,'entry');

    rtwprivate('getSTFInfo',h.ModelName,...
               'forceread',...
               true,...
               'ModelReferenceTargetType',...
               h.MdlRefBuildArgs.ModelReferenceTargetType);

    
    hardware = cs.getComponent('Hardware Implementation');
    hf = rtwprivate('get_rtw_info_hook_file_name',modelName);
    if (strcmp(hardware.TargetUnknown, 'off') &&...
        hf.FileExists &&...
        ~inbat &&...
        notMdlRef)
      msg = DAStudio.message('RTW:makertw:obsoleteInfoHook', hf.HookFileName);
      feval(h.DispHook{:},msg);
    end
    
    if strcmp(hardware.TargetUnknown, 'on')
      if hf.FileExists
          msg = DAStudio.message('RTW:makertw:hardwareImpDetails',...
                                 hf.HookFileName);
          feval(h.DispHook{:},msg);
          slprivate('setHardwareDevice', hardware, 'Target', '32-bit Generic');
          rtwprivate('importHardwareFromHook', hardware, hf.HookFileName,...
                     modelName);
      else
        if ~inbat && notMdlRef
            warnmsg = DAStudio.message('RTW:makertw:hardwareUnspecified');
            feval(h.DispHook{:},warnmsg);
        end
        slprivate('setHardwareDevice', hardware, 'Target', 'MATLAB Host');
      end
    end
    
    % Configure the RTWGenSettings and RTWOptions as well as other items
    % needed for running TLC.
    gensettings = ConfigForTLC(h);

    % Update the model's configuration set (if building model reference target)
    % if necessary and compare the config set of this model to any submodels
    % that exist.
    if ~h.InitRTWOptsAndGenSettingsOnly
      setup_config_set_for_model_reference(h, false);
    end
    
    % Get the RTWVerbose setting out of the config set, at this
    % point it has been set correctly for model reference.
    configSet = getActiveConfigSet(h.ModelName);
    rtwVerbose = strcmpi(get_param(configSet,'RTWVerbose'),'on');
    
    % Lock down active configuration set; after this point,
    % most set_param will not be successful
    lock(configSet);
    hDlg = get_param(h.ModelName, 'SimPrmDialog');
    if ~isempty(hDlg) && isa(hDlg, 'DAStudio.Dialog')
      refresh(hDlg);
    end

    % if not specified init RTWGenSettings and RTWOptions only
    if ~h.InitRTWOptsAndGenSettingsOnly

      % Continue with build configuration
      PrepareBuildArgs(h, gensettings, rtwVerbose);
      
      dispOpts.rtwVerbose = rtwVerbose;
      dispOpts.DispHook   = h.DispHook;

      % Get the saved checksum either from the buildArgs (ie it was
      % passed into slbuild), or load it from the binary mat file.
      % Pass the checksum into tlc_c to compare against the current
      % checksum after rtwgen to see if we need to generate code.
      [checksum, buildHooksChecksum, infoStruct] = ...
          LocGetChecksumAndInfoStruct(h, ~notMdlRef);

      % Pass the checkum into rtwgen via the buildArgs (this is used to return
      % early if the checksum matches)
      h.MdlRefBuildArgs.StoredChecksum = checksum;

      % The build hook checksum is used to ensure a full re-build in the case where a
      % build hook (e.g. code coverage settings) has changed
      h.MdlRefBuildArgs.StoredBuildHooksChecksum = buildHooksChecksum;
      
      % Save checksum matfile for the shared utilities directory
      curinfoStruct = rtwprivate('rtwinfomatman',...
                                 'saveAndcheckSharedUtils','binfo', ...
                                 h.ModelName,...
                                 h.MdlRefBuildArgs.ModelReferenceTargetType,...
                                 h.MdlRefBuildArgs.FirstModel,...
                                 h.MdlRefBuildArgs.BuildHooks,...
                                 h.MdlRefBuildArgs.TopModelPILBuild);
                             
      % Cache away for Stateflow
      h.BuildOpts.codeFormat = gensettings.CodeFormat;
      
      if h.MdlRefBuildArgs.OnlyCheckConfigsetMismatch
        msg = DAStudio.message('RTW:makertw:skippingCodeGen',h.ModelName);
        feval(h.DispHook{:}, msg);
        CleanupForExit(h,clearBuildInProgress);
        return;
      end
      
      tflName = get_param(configSet,'TargetFunctionLibrary');
      tflReg = RTW.TargetRegistry.getInstance();
      currTflReg = tflReg.getTfl(tflName);
      if ~rtwprivate('isTargetLangSupportedByTFL',currTflReg,...
                    get_param(configSet, 'TargetLang'))
          DAStudio.error('RTW:targetRegistry:cppCompilerExpected',tflName);
      end

      if (rtwprivate('checkCPPClassGeneration') ~= 0)
          if strcmp(get_param(configSet, 'CPPClassGenCompliant'), 'off') &&...
             strcmp(get_param(configSet, 'TargetLang'), 'C++ (Encapsulated)')
              DAStudio.error('RTW:fcnClass:targetNotSupportCPPClass');
          end
      end
      
      % If generating C++, ensure a C++ compiler is configured.
      % Must be done after call to PrepareBuildArgs.
      CheckCompilerCompatible(h);
      
      %
      % remove previously auto generated TLC subdirectory
      %
      if ~system_dependent('CheckMalloc')
          generatedTLCDir = fullfile(h.BuildDirectory, h.GeneratedTLCSubDir);
          %
          % Remove previously auto generated TLC subdirectory from the MATLAB
          % path. Notice that original MATLAB path will be restored at the end
          % of code generation.
          %
          if ~isempty(findstr(path, generatedTLCDir))
            rmpath(generatedTLCDir);
          end
          %
          % Make sure that any relative path to the auto generated TLC
          % subdirectory is also being removed from the MATLAB path.
          %
          relGeneratedTLCDir = strcat('.', strrep(generatedTLCDir, pwd, ''));
          if ~isempty(findstr(path, relGeneratedTLCDir))
            rmpath(relGeneratedTLCDir);
          end
          if exist(generatedTLCDir, 'dir')
              [success, message, messageID] = rmdir(generatedTLCDir,'s');
              if ~success
                  error(messageID, message);
              end
          end
      end      
      
      % determine if this is a top-model PIL build
      if (isfield(h.MdlRefBuildArgs,'TopModelPILBuild') ...
              && h.MdlRefBuildArgs.TopModelPILBuild)
          isTopModelPIL = true;
      else
          isTopModelPIL = false;
      end      
    
      % determine whether the CodeInfo-based SIL/PIL block should be
      % created
      %
      % protect against s-function code format
      % top-model PIL overrides creating a CodeInfo-based SIL or PIL block
      if strcmp(h.BuildOpts.codeFormat, 'Embedded-C') && ~isTopModelPIL
          [createSILPILBlock, ...
           silPILBlockIsSILMode] = rtwprivate('isCreateSILPILBlock', ...
                                              configSet);          
      else
          createSILPILBlock = false;
          silPILBlockIsSILMode = [];
      end
      
      if createSILPILBlock                                    
          % early check for a valid SIL/PIL configuration
          if silPILBlockIsSILMode
            rtw.pil.ModelBlockPIL.getSilConnectivityConfig(h.ModelName);
          else
            rtw.pil.ModelBlockPIL.getPilConnectivityConfig(h.ModelName);    
          end
      end
          
      [~, sysFileName] = fileparts(h.SystemTargetFilename);
      if strcmp(sysFileName, 'plc')
          
          % generate PLC code using cgir_plc backend
          sfprivate('plc_builder', 'make_plc', h);
          
          % Call user defined RTW hook exit method
          callMakeHook(h,'exit');
          
      else
          
          %--------------------------------------------------------------------%
          % Invoke the Target Language Compiler to generate the specific
          % language
          %--------------------------------------------------------------------%
          buildResult = tlc_c(h,...
              h.ModelName, ...
              h.RTWRoot, ...
              h.SystemTargetFilename, ...
              dispOpts, ...
              h.BuildDirectory, ...
              gensettings.CodeFormat,...
              h.MdlRefBuildArgs, ...
              anchorDir, checksum);
          
          % If we don't need to build
          %  (1) set the bd parameter RTWCodeWasUptodate to true if the 
          %      checksums are the same to indicate that the rtw code was
          %      up-to-date and
          %      build was aborted.
          %  (2) resave the old infoStruct in the binary file.
          % This parameter is read in
          %  toolbox/simulink/simulink/private/update_model_reference_targets.m
          %
          if h.MdlRefBuildArgs.CheckCodeDonotRebuild || buildResult.codeWasUpToDate
              
              if buildResult.codeWasUpToDate
                  set_param(modelName, 'RTWCodeWasUptodate', 'on');
              end
              if ~isempty(infoStruct)
                  % Need to make sure that when we resave the binfo, we use an up-to-date
                  % minfoFileRevision number to avoid unnecessary rebuilds.
                  infoStruct.minfoFileRevision = curinfoStruct.minfoFileRevision;

                  rtwprivate('rtwinfomatman', ...
                      'save','binfo', ...
                      h.ModelName, ...
                      h.MdlRefBuildArgs.ModelReferenceTargetType,...
                      infoStruct);
              end
          else
              
              % Call user defined RTW hook after_tlc_build method
              callMakeHook(h,'after_tlc');
                          
              % Pass flag to build object code only for CodeInfo-based SIL/PIL                         
              if isTopModelPIL || createSILPILBlock
                  suppressExe = true;
              else
                  suppressExe = false;
              end
              
              % buildResult = { rtwFile, modules, noninlinedSFcns, listSFcns, ...
              %                 buildNotNeeded, runTimeParameters}
              h.BuildOpts = CreateBuildOpts(h, ...
                  h.ModelHandle, ...
                  h.SystemTargetFilename, ...
                  rtwVerbose, ...
                  h.CompilerEnvVal, ...
                  buildResult, ...
                  gensettings.CodeFormat, ...
                  suppressExe);
              
              % fill in the standrd info in the BuildInfo object.  This is done
              % after the BuildOpts are created, so that the same logic is
              % not duplicated.
              h.BuildInfo.addStandardInfo(h.BuildOpts);
              
              % Call user defined RTW hook before_make method
              callMakeHook(h,'before_make');
              
              rpt_generated_flag = false; % flag to indicate if report has been displayed
              % Generate HTML report, if necessary, here if system target file is not
              % autosar (i.e. no extra files to be added to report later)
              if (~strcmp(get_param(h.ModelName,'SystemTargetFile'),'autosar.tlc') ...
                  && ~strcmp(get_param(h.ModelName,'SystemTargetFile'),'tlmgenerator.tlc') ...
                  && ~rtwprivate('rtwreport', 'hasCustomFile', h.ModelName))
                  genHTMLreport(h);
                  rpt_generated_flag = true;
              end
              
              try
                  % creates a makefile from the templateMakefile which is then used by
                  % make to create the image
                  rtw_c(h,...
                      h.ModelName, ...
                      h.TemplateMakefile, ...
                      h.BuildOpts, ...
                      h.BuildArgs,...
                      curinfoStruct);
              catch exc
                  % if there is an error during compilation, then display
                  % HTML report if necessary, if not already displayed
                  if ~rpt_generated_flag
                    genHTMLreport(h);
                  end
                  throw(exc);
              end
              
              % Call user defined RTW hook after_make method
              callMakeHook(h,'after_make');
              
             if (~rpt_generated_flag && strcmp(get_param(h.ModelName,'SystemTargetFile'),'tlmgenerator.tlc'))
                  genHTMLreport(h);
                  rpt_generated_flag = true;
              end

              % Call user defined RTW hook exit method
              callMakeHook(h,'exit');
              
              % Generate HTML report if necessary, if not already displayed
              if ~rpt_generated_flag
                genHTMLreport(h);
              end
              
              % CodeInfo-based SIL/PIL block
              % SIL will have already thrown an error if the target is
              % not makefile based!                                                                       
              if createSILPILBlock && ~h.BuildOpts.generateCodeOnly
                  % create the SIL/PIL block
                  locCreateSILPILBlock(silPILBlockIsSILMode, h.ModelName);
              end
          end    
      end
      
      % clear the Current TFL since it is only valid during the build.
      set_param(h.modelName, 'TargetFcnLibHandle', []);
        
    end
  catch exc
    
      sle =  sllasterror;
      % the call to the exit hook may cause an error because some of the
      % args may not be set up correctly, and/or the user code
      % itself could have an error.
      try
          % The user hook may need to clean some things up, so call the
          % exit hook
          callMakeHook(h,'error');
      catch ignoreExc %#ok<NASGU>
          % silently catch this error, since it may simply be caused by the
          % args not being good.
      end
      
      CleanupForExit(h,clearBuildInProgress,anchorDir);
      
      % clear the Current TFL
      set_param(h.modelName, 'TargetFcnLibHandle', []);

      % An error occurred above, clean up and error out again, echoing the last
      % error.  Also, since this is not a valid build, remove the binary
      % info file so we will try to rebuild the next time.
      binfo_name = rtwprivate('rtwinfomatman','getMatFileName', ...
                              'binfo',h.ModelName,...
                              h.MdlRefBuildArgs.ModelReferenceTargetType);
      if (exist(binfo_name, 'file') ~= 0)
          delete(binfo_name);
      end
      
      % restore the lasterror since it may have been overwritten, and
      % rethrow it
      sllasterror(sle);
      
      rethrow(exc);
  end

  % Restore settings (locked and dirty flags, start time, and code reuse
  % feature) before exit and restore working directory.
  CleanupForExit(h,clearBuildInProgress,anchorDir);

%endfunction make_rtw


%------------------------------------------------------------------------------
function [oChecksum, oBuildHooksChecksum, oInfoStruct] = ...
        LocGetChecksumAndInfoStruct(h,  isMdlRef)
    
  oChecksum   = [];
  oBuildHooksChecksum = [];
  oInfoStruct = [];

  % For model reference targets, we try to load the checksum
  % from the saved binary info file.  But if a checksum was
  % passed into this function, then use that value for the comparison.
  % If the buildargs says not to use the checksum then return an empty array.
  if h.MdlRefBuildArgs.UseChecksum && ...
        (isMdlRef || ~isempty(h.MdlRefBuildArgs.StoredChecksum))
    oChecksum = h.MdlRefBuildArgs.StoredChecksum;
    oBuildHooksChecksum = h.MdlRefBuildArgs.StoredBuildHooksChecksum;

    try
      oInfoStruct = rtwprivate('rtwinfomatman','load','binfo', ...
                               h.ModelName,h.MdlRefBuildArgs.ModelReferenceTargetType);
      if isempty(oChecksum)
        oChecksum = oInfoStruct.checkSum;
        oBuildHooksChecksum = oInfoStruct.buildHooksCheckSum;
      end
    catch ignoreExc %#ok<NASGU>
      oInfoStruct = [];
    end
  end
  
%endfunction

function locCreateSILPILBlock(isSILMode, codeName)
% codeName will be correct for a top-level model, but
% must be overridden for a subsystem build owing to the use of the
% temporary model name.
%
% getSourceSubsystemName will provide:
%
% Subsystem Build: Simulink system path
% Top-Level Build: Empty
%
componentPath = rtwprivate('rtwattic', 'getSourceSubsystemName');
if isempty(componentPath)
    componentPath = codeName;
end

block = [];
% make sure we leave pwd in tact
codeDir = cd('..');
c = onCleanup(@()cd(codeDir));                   
%
pil_block_configure(block, ...
    componentPath, ...
    codeDir, ...
    isSILMode);
%End of Function locCreateSILOrPILBlock
