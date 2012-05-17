function oString = setup_for_visual(args)
%
% Function: setup_for_visual =================================================
% Abstract:
%
%       Configure the build process for Visual (normal mode of operation) or
%       (other, slightly hacky mode of operation) return a string giving
%       suggestions for how to set the "MSDevDir" or "DevEnvDir" environment
%       variable
%
%       When configuring the build process for Visual, this function wraps the
%       raw make command, args.makeCmd (e.g. 'nmake -f model.mk MAT_FILE=1') in
%       a batch (.bat) file that sets up some environment variables needed
%       during the build process.
%------------------------------------------------------------------------------
%

% Copyright 1994-2010 The MathWorks, Inc.
% $Revision $

  if isfield(args, 'EnvVarSuggestions')

      [~, oString] = LocGetEnvVarSuggestions(LocGetMSD);
      
      return;
  else
    
      % if the mexopts struct was not set, then it could be because the
      % TemplateMakefile param was explicitly set to a specific TMF.  Since the
      % TMF is targeted for MSVC (that's why this function was called), try
      % getting a struct for an installed Microsoft compiler.
      if isempty(args.mexOpts)
          args.mexOpts = rtwprivate('getMexCompilerInfo',...
                                    'manufacturer','Microsoft');
      end
      
      % if the mexOpts struct is set, and it's in the 'new style' compiler
      % support, then call the new bat file setup.  otherwise default to
      % the old style for now.
      if (~isempty(args.mexOpts) &&...
          ismember(args.mexOpts.compStr,...
                   {'Microsoft-10.0'...
                    'Microsoft-10.0exp'}))
          [oString bat_struct] = LocNewSetup(args);
      else
          [oString bat_struct] = LocNormalSetup(args);
      end
  end

  % this may be a non-model based build.  If so, then the make settings
  % object will not exist.  The mexopts file can be left blank here, as
  % buildInfo will have it set appropriately.
  if (RTW.areModelsOpen(args.modelName))
      makeRTWObj=get_param(args.modelName,'MakeRTWSettingsObject');
      %
      % rtw.connectivity.MakefileBuilder calls genMakefileAndBuild when
      % models are open (areModelsOpen returns true) but there is no
      % MakeRTWSettingsObject.
      %
      % In this case, skip setting up InstallDirmexopts and CompilerName,
      % which are used to configure MEX_OPT_FILE in genMakefileAndBuild.
      %
      % MEX_OPT_FILE is not required by the MakefileBuilder's
      % MAKEFILEBUILDER_TGT in the TMF's.
      %
      if ~isempty(makeRTWObj)
          makeRTWObj.InstallDirmexopts = ['"$(MATLAB_BIN)\$(ML_ARCH)\mexopts\'...
              bat_struct.originalmexOpts '.bat"'];
          makeRTWObj.BuildInfo.addTMFTokens('|>VISUAL_VER<|', bat_struct.vcverOnes, 'COMPILER_VERSION');
          % if the BuildInfo Object InstallDirmexopts is empty, then we need to
          % update it.
          if isempty(makeRTWObj.BuildInfo.InstallDirmexopts)
              makeRTWObj.BuildInfo.InstallDirmexopts = ...
                  makeRTWObj.InstallDirmexopts;
          end
          if ~bat_struct.specified_via_makeCmd
              makeRTWObj.CompilerName = '_vc.tmf';
          else
              makeRTWObj.CompilerName = 'MAKECMD_vc.tmf';
          end
      end
  end
  
%endfunction setup_for_visual


function [oMakeCmd bat_struct] = LocNormalSetup(args)

  msd = LocGetMSD;
  [bat_struct.msDevDir additionalInfo] = 	LocGetMSDevDir(args.makeCmd, args.compilerEnvVal, msd);
  bat_struct.specified_via_makeCmd = additionalInfo.specified_via_makeCmd;

  bat_struct.platformSDKdir  = ''; % assume unknown
  bat_struct.msVcDir  = ''; % assume unknown
  bat_struct.vcvars32 = ''; % assume unknown
  bat_struct.vcverOnes    = ''; % assume unknown
  bat_struct.vcverHundreds = ''; % assume unknown
  bat_struct.originalmexOpts = ''; % assume unknown

  if ~isempty(bat_struct.msDevDir)
      switch additionalInfo.msvcver
        case {'600'}
          bat_struct.devstudio = RTW.reduceRelativePath(fullfile(bat_struct.msDevDir, '..', '..'));
          bat_struct.msVcDir= fullfile(bat_struct.devstudio, msd{2}.VCRelLoc);
          bat_struct.vcvars32 = [matlabroot, ...
                              '\toolbox\rtw\rtw\private\vcvars32_' msd{2}.HundredsVers '.bat'];
          bat_struct.vcverOnes = msd{2}.OnesVers;
          bat_struct.vcverHundreds = msd{2}.HundredsVers;
          bat_struct.originalmexOpts = msd{2}.originalmexOpts; 			

        case {'800'}
          bat_struct.devstudio = RTW.reduceRelativePath(fullfile(bat_struct.msDevDir, '..', '..'));
          bat_struct.msVcDir= fullfile(bat_struct.devstudio, msd{3}.VCRelLoc);
          bat_struct.vcvars32 = [matlabroot, ...
                              '\toolbox\rtw\rtw\private\vcvars32_' msd{3}.HundredsVers '.bat'];
          bat_struct.vcverOnes = msd{3}.OnesVers;
          bat_struct.vcverHundreds = msd{3}.HundredsVers;
          bat_struct.originalmexOpts = msd{3}.originalmexOpts; 

        otherwise
          % no version information or invalid version setting. Try to get
          % it by matching the path pattern
          for i=1:length(msd)
              
              % If "i" is the correct DevStudio, the DevStudio root directory can be had by
              % stripping msd{i}.IDERelLoc off the end of bat_struct.msDevDir.  If "i" is not the
              % correct DevStudio, bat_struct.devstudio will end up empty.
              
              bat_struct.devstudio = LocPrefix(bat_struct.msDevDir, msd{i}.IDERelLoc);
              
              % If "i" is the correct DevStudio, bat_struct.msDevDir:
              %
              %    (a) contains the batch file msd{i}.uniqueFileRel and
              %    (b) ends in msd{i}.IDERelLoc.

              if ~isempty(dir([bat_struct.msDevDir, msd{i}.uniqueFileRel])) && ...
                      ~isempty(bat_struct.devstudio)
                  bat_struct.msVcDir  = [bat_struct.devstudio msd{i}.VCRelLoc];

                  % Here we set the variable bat_struct.vcvars32 to our own version of msd{i}.VarsBatRel,
                  % which, unlike the original, fills in various environment variables
                  % based on other environment variables "passed in" rather than having
                  % these variables hard-coded and based on an installation location.
                  
                  bat_struct.vcvars32 = [matlabroot, ...
                                      '\toolbox\rtw\rtw\private\vcvars32_' msd{i}.HundredsVers '.bat'];
                  bat_struct.vcverOnes = msd{i}.OnesVers;
                  bat_struct.vcverHundreds = msd{i}.HundredsVers;
                  bat_struct.originalmexOpts = msd{i}.originalmexOpts;
                  break;
              end % if
          end % for
      end % switch

  end % if ~isempty(bat_struct.msDevDir)

  if ~isempty(bat_struct.msVcDir)
      oMakeCmd = LocWriteBatFile(args.makeCmd, args.modelName, args.verbose, ...
          bat_struct, args.isSimBuild);
  else
      LocIssueMSDevError(bat_struct.msDevDir, msd);
  end

%endfunction LocNormalSetup

function makeCmdOut = LocWriteBatFile(makeCmd, modelName, verbose, bat_struct,...
    isSimBuild)
% Emit batch file code for an RTW build under MSVC

  endl = sprintf('\n');

  cmdFile = ['.\',modelName, '.bat'];
  cmdFileFid = fopen(cmdFile,'wt');
  if ~verbose
      fprintf(cmdFileFid, '@echo off\n');
  end
  fprintf(cmdFileFid, 'set MATLAB=%s\n', matlabroot); % for mpc555pil
  fprintf(cmdFileFid, 'set MSVCDir=%s\n',bat_struct.msVcDir);
  if strcmp(bat_struct.vcverHundreds,'800free')
      fprintf(cmdFileFid, '%s',['set MSSdk=' bat_struct.platformSDKdir endl]);
	  fprintf(cmdFileFid, '%s',['@if "%MSSdk%"=="" goto Usage1' endl]);
  end

  fprintf(cmdFileFid, '%s', endl);
  
  % check local machine env vars
  switch bat_struct.vcverHundreds
    case {'600'}
      % older versions (pre 7.1) need the MSDevDir env var set
      fprintf(cmdFileFid, 'set MSDevDir=%s\n',bat_struct.msDevDir);
    case {'800'}
      LocEnvCheck(cmdFileFid, 'INCLUDE', [bat_struct.msVcDir '\platformsdk\include']);
  end
  LocEnvCheck(cmdFileFid, 'INCLUDE', [bat_struct.msVcDir  '\include']);
  LocEnvCheck(cmdFileFid, 'PATH',    [bat_struct.msVcDir  '\bin']);
  fprintf(cmdFileFid, 'goto make\n');

  % Local machine has not setup env vars that are needed to build project, call
  % vcvars32_verHundreds.bat to set them
  fprintf(cmdFileFid, '\n:vcvars32\n');
  switch bat_struct.vcverHundreds
    case {'600'}
      fprintf(cmdFileFid,'set VSCommonDir=%s\n', [bat_struct.devstudio '\common']);
    case {'800'}
      fprintf(cmdFileFid, '%s', ...
              ['set VSINSTALLDIR='    bat_struct.devstudio                 endl ...
               'set VCINSTALLDIR='    bat_struct.msVcDir                   endl ...
               'set FrameworkSDKDir=' bat_struct.devstudio '\SDK\v2.0'     endl ...
               'set FrameworkDir='    bat_struct.devstudio '\Framework'    endl]);

    case {'900'}
      fprintf(cmdFileFid, '%s', ...
              ['set VSINSTALLDIR='    bat_struct.devstudio                 endl ...
               'set VCINSTALLDIR='    bat_struct.msVcDir                   endl ...
               'set FrameworkSDKDir=' bat_struct.devstudio '\SDK\v3.5'     endl]);
  end

  fprintf(cmdFileFid, '%s\n', ['call "', bat_struct.vcvars32,'"']);

  % clear the error level just before the make call (any successful command
  % will do it), so that we only show the make errorlevel.
  fprintf(cmdFileFid, '\n:make\ncd .\n');

% Write out any build hook environment commands
if ~isSimBuild
    rtw.pil.BuildHook.writePcBuildEnvironmentCmds(cmdFileFid, ...
                                                  modelName);
end
  
  
  fprintf(cmdFileFid, '%s\n',	makeCmd);

  % The program nmake.exe does not print an error message to stdout in certain
  % circumstances so here we make sure that some printed manifestation of an
  % error will be emitted if an error occurs.  In particular, nmake prints no
  % error message if a DLL cannot be found since this error is reported by a
  % Windows system dialog that appears who knows where.

  % note that the way errorlevel works in msdos is that if the error level is
  % greater than or equal to the error level checked, it evaluates to true.  So
  % the statement 'if errorlevel 1...' will return true if any error has  
  % occurred.
  
  % This statement used to be 'if not errorlevel 0...' which always evaluates
  % to false, because 'errorlevel 0' is always true (errorlevel is greater
  % than or equal to 0).
  fprintf(cmdFileFid, '@if errorlevel 1 goto error_exit\n');
  fprintf(cmdFileFid, 'exit /B 0\n');

  if strcmp(bat_struct.vcverHundreds,'800free')
	  fprintf(cmdFileFid, '\n:Usage1\n');
	  fprintf(cmdFileFid, '%s\n', ['@echo Error: Build with MSVC 8.0 express edition requires'...
		  ' MSSdk being defined as the location of Microsoft platformSDK installation.']);
      fprintf(cmdFileFid, '@goto error_exit\n');	  
  end
  
  % in order to get the bat file to report an error to the caller, a bad call
  % must be made as the LAST line in the file.
  fprintf(cmdFileFid, '\n:error_exit\n');
  fprintf(cmdFileFid, '%s\n', ['echo The make command returned an '...
                      'error of %errorlevel%']);
  fprintf(cmdFileFid, 'An_error_occurred_during_the_call_to_make\n');

  fclose(cmdFileFid);
  makeCmdOut = cmdFile;

%endfunction LocWriteBatFile


function LocEnvCheck(cmdFileFid, var, val)
% Emit batch file code to check that environment variable "var" has value "val".

  fprintf(cmdFileFid, '%s\n', ...
    ['"' matlabroot,'\rtw\bin\win32\envcheck" ' var ' "' val '"']);
  fprintf(cmdFileFid, '%s\n', 'if errorlevel 1 goto vcvars32');

%endfunction LocEnvCheck

function LocIssueMSDevError(msDevDir, msd)
% Issue an error saying that no MSDev installation is found

  [checkEnvVal correctSetting] = LocGetEnvVarSuggestions(msd);

  env = 'MSDevDir or DevEnvDir';
  
  DAStudio.error('RTW:compilerConfig:invalidEnvVariable',...
                 env, msDevDir, checkEnvVal, env, correctSetting,...
                 fullfile(prefdir,'mexopts.bat'));
    
    
%endfunction LocIssueMSDevError


function [oVCVarsBats, oMSDevDirs] = LocGetEnvVarSuggestions(msd)
% Issue an error saying that no MSDev installation is found

  oVCVarsBats = '';
  oMSDevDirs = '';
  for i=1:length(msd)

    endStr = ['(for Visual C/C++ ' msd{i}.OnesVers ')' sprintf('\n')];

    ideLocVar =  ['%' msd{i}.IDELocVar '%'];

    varsBatLoc = ['  ' ideLocVar msd{i}.VarsBatRel];

    setCmd =     ['  set ' ideLocVar '=<VisualRoot>' msd{i}.IDERelLoc];

    oVCVarsBats = [oVCVarsBats sprintf('%-45s',varsBatLoc) endStr];%#ok

    oMSDevDirs = [oMSDevDirs sprintf('%-45s',setCmd) endStr];%#ok
  end

%endfunction LocGetEnvVarSuggestions

function [msDevDir additionalInfo] = LocGetMSDevDir(makeCmd, compilerEnvVal, msd)
% Try to get a value for the developer studio IDE executable directory by
% various means

  additionalInfo.specified_via_makeCmd = false; % assume false
  additionalInfo.platformSDKdir = ''; % assume unknown
  additionalInfo.msvcver = ''; % assume unknown
  
  m = LocGetMSDevDirFromRootFromCmd(msd, makeCmd, 'DEVSTUDIO_LOC');

  if isempty(m)
      
      m = parsestrforvar(makeCmd, 'MSDevDir_LOC');
  end

  % so VC location is specified via makeCmd 
  if ~isempty(m)
      additionalInfo.specified_via_makeCmd = true;
  end
  
  if isempty(m)
  
      m = LocGetMSDevDirFromRoot(msd, compilerEnvVal, [], true);
      
  end

  % if the user has called mex -setup and set up a visual compiler, AND the
  % model explicitly has a tmf that ends in '_vc.tmf' re-scan the mexopts
  % and get the specific version that was set up.  otherwise the default
  % preference order based on the getenv checks below will be used.
  if isempty(m)
      [m, ~, otherOpts] = parse_mexopts_for_envval('_vc.tmf');
      additionalInfo.msvcver = otherOpts.msvcver;
      additionalInfo.platformSDKdir = otherOpts.platformSDKdir;
  
  end

  % check for a parallel build compiler
  if isempty(m)
      comp = rtwprivate('rtwParallelBuildCompiler','get');
      if ~isempty(comp)
          m = LocGetMSDevDirFromRoot(msd, comp.comp.Location, 'VS90COMNTOOLS');
          additionalInfo.msvcver = regexprep(comp.comp.Version,...
                                             '\.([0-9])',...
                                             '$10');
      end
  end
  
  % if failed finding VS install information from command line or mexopts.bat,
  % try search local machine environment variables for available ones

  if isempty(m)
      %VisualStudio 9
      vstooldir = getenv('VS90COMNTOOLS'); 
      if ~isempty(vstooldir)
          m = LocGetMSDevDirFromRoot(msd, fullfile(vstooldir,'..','..'),'VS90COMNTOOLS'); 
      end
  end

  if isempty(m)
      %VisualStudio 8
      vstooldir = getenv('VS80COMNTOOLS'); 
      if ~isempty(vstooldir)
          m = LocGetMSDevDirFromRoot(msd, fullfile(vstooldir,'..','..'),'VS80COMNTOOLS'); 
      end
  end

  if isempty(m)
      %Visual C++ 6.0
      m = LocGetMSDevDirFromRootFromEnv(msd, 'VISUAL_STUDIO');

  end
  if isempty(m)

    m = getenv('MSDevDir');

  end
  if isempty(m)

    m = getenv('DevEnvDir');

  end

  msDevDir = RTW.reduceRelativePath(lower(m));

%endfunction LocGetMSDevDir

function msd = LocGetMSD()

% Returns a data structure describing the variations in file naming and
% directory structure in various versions of MSVC.

  msd{1}.IDERelLoc = '\common7\ide'; % msvc 9
  msd{2}.IDERelLoc = '\common\msdev98'; % msvc 6
  msd{3}.IDERelLoc = '\common7\ide'; % msvc 8 

  msd{1}.IDELocVar = 'DevEnvDir';
  msd{2}.IDELocVar = 'MSDevDir';
  msd{3}.IDELocVar = 'DevEnvDir';

  msd{1}.VarsBatRel = '\..\tools\vsvars32.bat';
  msd{2}.VarsBatRel = '\..\..\vc98\bin\vcvars32.bat';
  msd{3}.VarsBatRel = '\..\tools\vsvars32.bat';

  msd{1}.uniqueFileRel = '\..\..\Common7\IDE\msenc90.dll';
  msd{2}.uniqueFileRel = '\..\..\vc98\bin\vcvars32.bat';
  msd{3}.uniqueFileRel = '\..\..\VC\platformSDK';
  
  msd{1}.VCRelLoc = '\VC';
  msd{2}.VCRelLoc = '\vc98';
  msd{3}.VCRelLoc = '\VC';

  % This field is used to create ['vcvars32_' HundredsVers'.bat' filename, 
  % make sure they match
  msd{1}.HundredsVers = '900';
  msd{2}.HundredsVers = '600';
  msd{3}.HundredsVers = '800';

  % Used to set makefile flag VISUAL_VER.
  msd{1}.OnesVers = '9.0';
  msd{2}.OnesVers = '6.0';
  msd{3}.OnesVers = '8.0';

  % Following strings defines the template/original mexOpts.bat file location
  msd{1}.originalmexOpts = 'msvc90opts'; 
  msd{2}.originalmexOpts = 'msvc60opts'; 
  msd{3}.originalmexOpts = 'msvc80opts'; 
%endfunction LocGetMSD

function m = LocGetMSDevDirFromRootFromCmd(msd, iCmd, iSrcVar)

  m = LocGetMSDevDirFromRoot(msd, parsestrforvar(iCmd, iSrcVar), iSrcVar);

%endfunction


function m = LocGetMSDevDirFromRootFromEnv(msd, iSrcVar)

  m = LocGetMSDevDirFromRoot(msd, getenv(iSrcVar), iSrcVar);

%endfunction


function oMSDevDir = LocGetMSDevDirFromRoot(msd, iRoot, iSrcVar, silent)
%
% Try to get a value for the MSDev IDE dir from the MSDev root dir
%
  if nargin < 4
    silent = false;
  end
  oMSDevDir = '';

  if ~isempty(iRoot)

    iRoot = lower(iRoot);

    for i=1:length(msd)
      IDEAbsLoc = [iRoot msd{i}.IDERelLoc];
      if exist(IDEAbsLoc, 'dir')
        oMSDevDir = IDEAbsLoc;
      end % if
    end % for

    if isempty(oMSDevDir)
      if silent
        oMSDevDir = iRoot;
        return
      end

      aba = '(angle brackets added):';
      inst = 'an installation of Microsoft Developer Studio';
      action = ['to find ' inst];
      VarErrStr = ['variable: ' iSrcVar];
      DAStudio.error('RTW:compilerConfig:incompatibleVersion',...
                     action,aba, iRoot,action,VarErrStr,inst,inst,inst);
    end
  end

%endfunction LocGetMSDevDirFromRoot

function r = LocPrefix(str, suffix)
% If "suffix" is a suffix of "str", return str without "suffix".  Otherwise
% return the empty string.

  r = '';
  startLocs = strfind(str, suffix);
  st = length(str);
  su = length(suffix);

  if ~isempty(startLocs) && (st - su + 1 == startLocs(end))
    r = str(1:startLocs(end)-1);
  end

%endfunction LocPrefix        


%=============================================================================
% Function: locnewSetup 
%
% inputs:
%    comp
%
%
% returns:
%
%
%=============================================================================
function [oString bat_struct] = LocNewSetup(args)

  bat_struct=[];

  bat_struct.vcverOnes             = args.mexOpts.comp.Version;
  bat_struct.originalmexOpts       = args.mexOpts.originalMexOpts;
  bat_struct.specified_via_makeCmd = false;

  vcvars = ['"%' args.mexOpts.envVar '%' args.mexOpts.batFileLoc '" ' ...
           args.mexOpts.batFileArgs];
  
  
  % Emit batch file code for an RTW build under MSVC

  cmdFile = ['.\',args.modelName, '.bat'];
  cmdFileFid = fopen(cmdFile,'wt');
  if ~args.verbose
    fprintf(cmdFileFid, '@echo off\n');
  end
  
  fprintf(cmdFileFid, 'call %s\n', vcvars);
  
  % clear the error level just before the make call (any successful command
  % will do it), so that we only show the make errorlevel.
  fprintf(cmdFileFid, '\ncd .\n');
  fprintf(cmdFileFid, '%s\n', args.makeCmd);

  % The program nmake.exe does not print an error message to stdout in certain
  % circumstances so here we make sure that some printed manifestation of an
  % error will be emitted if an error occurs.  In particular, nmake prints no
  % error message if a DLL cannot be found since this error is reported by a
  % Windows system dialog that appears who knows where.

  % note that the way errorlevel works in msdos is that if the error level is
  % greater than or equal to the error level checked, it evaluates to true.  So
  % the statement 'if errorlevel 1...' will return true if any error has  
  % occurred.
  
  % This statement used to be 'if not errorlevel 0...' which always evaluates
  % to false, because 'errorlevel 0' is always true (errorlevel is greater
  % than or equal to 0).
  fprintf(cmdFileFid, '@if errorlevel 1 goto error_exit\n');
  fprintf(cmdFileFid, 'exit /B 0\n');

  % in order to get the bat file to report an error to the caller, a bad call
  % must be made as the LAST line in the file.
  fprintf(cmdFileFid, '\n:error_exit\n');
  fprintf(cmdFileFid, '%s\n', ['echo The make command returned an '...
                      'error of %errorlevel%']);
  fprintf(cmdFileFid, 'An_error_occurred_during_the_call_to_make\n');

  fclose(cmdFileFid);
  oString = cmdFile;

return;
%End of Function locnewSetup

% LocalWords:  hacky Env nmake mexopts TMF Dirmexopts MAKEFILEBUILDER TGT TMF's
% LocalWords:  vc tmf MAKECMD vcvars msd devstudio pil Sdk
