function oString = setup_for_visual_x64(args)
%
% Function: setup_for_visual_x64 =====================================================
% Abstract:
%
%       Configure the build process for Visual C++ for the x64 platform
%
%       When configuring the build process for Visual, this function wraps the
%       raw make command, args.makeCmd (e.g. 'nmake -f model.mk MAT_FILE=1') in
%       a batch (.bat) file that sets up some environment variables needed
%       during the build process.
%-------------------------------------------------------------------------------
%

% Copyright 1994-2010 The MathWorks, Inc.
% $Revision.3 $

  if isfield(args, 'EnvVarSuggestions')

      vsInfo = locGetMSVCVerInfo();
      oString = DAStudio.message('RTW:buildProcess:missingMSVCEnvironment',...
                                 sprintf('%s\n',vsInfo(:).envVar));
      return;
  end

  % if the mexopts struct was not set, then it could be becasue the
  % TemplateMakefile param was explicitly set to a specific TMF.  Since the TMF
  % is targeted for MSVC (that's why this function was called), try getting a
  % struct for an installed Microsoft compiler.
  if isempty(args.mexOpts)
      args.mexOpts = rtwprivate('getMexCompilerInfo',...
                                'manufacturer','Microsoft');
  end
  
  % if the mexOpts struct si set, and it's in the 'new style' compielr support,
  % then call the new bat file setup.  otherwise default to the old style for
  % now.
  if (~isempty(args.mexOpts) &&...
      ismember(args.mexOpts.compStr,...
               {'Microsoft-10.0'...
                'Microsoft-10.0exp',...
                'Microsoft-9.0exp'}))
      [oString, msvcver] = LocNewSetup(args);
      
  else

      msvcver = locGetMSVCVer(args.makeCmd, args.mexOpts);

      oString = LocWriteBatFile(args.makeCmd,...
                                args.modelName,...
                                msvcver,...
                                args.verbose,...
                                args.isSimBuild);

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
          makeRTWObj.InstallDirmexopts = msvcver.mexopts;
          makeRTWObj.BuildInfo.addTMFTokens('|>VISUAL_VER<|',...
              msvcver.onesVer,...
              'COMPILER_VERSION');
          % if the BuildInfo object InstallDirmexopts is empty, then we need to
          % update it.
          if isempty(makeRTWObj.BuildInfo.InstallDirmexopts)
              makeRTWObj.BuildInfo.InstallDirmexopts =...
                  makeRTWObj.InstallDirmexopts;
          end
          makeRTWObj.CompilerName = '_vcx64.tmf';
      end
  end

%endfunction setup_for_visual_x64

function [makeCmdOut, msvcver] = LocWriteBatFile(makeCmd, modelName, msvcver, ...
                                                 verbose, isSimBuild)
% Emit batch file code for an RTW build under MSVC

  cmdFile = ['.\',modelName, '.bat'];
  cmdFileFid = fopen(cmdFile,'wt');
  if ~verbose
    fprintf(cmdFileFid, '@echo off\n');
  end
  
  fprintf(cmdFileFid, 'call %s\n', msvcver.vcvars);
  
  % Write out any build hook environment commands
  if ~isSimBuild
      rtw.pil.BuildHook.writePcBuildEnvironmentCmds(cmdFileFid, ...
                                                    modelName);
  end
  
  % clear the error level just before the make call (any successful command
  % will do it), so that we only show the make errorlevel.
  fprintf(cmdFileFid, '\ncd .\n');
  fprintf(cmdFileFid, '%s\n', makeCmd);

  % The program nmake.exe does not print an error message to stdout in certain
  % circumstances so here we make sure that some printed manifestation of an
  % error will be emitted if an error occurs.  In particular, nmake prints no
  % error message if a DLL cannot be found since this error is reported by a
  % Windows system dialog that appears who knows where.

  % note that the way errorlevel works in ms dos is that if the error level is
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
  makeCmdOut = cmdFile;

%endfunction LocWriteBatFile

%=============================================================================
% Function: locGetMSVCVer 
%
% inputs:
%    makeCmd
%    mexOpts
%
%
% returns:
%    msvcver
%
%
%=============================================================================
function msvcver = locGetMSVCVer(makeCmd,mexOpts)

    msvcver=[];

    vsInfo = locGetMSVCVerInfo();

    
    % first check for DEVSTUDIO_LOC on the make command-------------------
    DSLoc = parsestrforvar(makeCmd, 'DEVSTUDIO_LOC');
    if ~isempty(DSLoc)
        % for 64 bit windows, the compiler must be installed locally, check the
        % directory against the env vars for the different versions.  The
        % DEVSTUDIO_LOC will usually be the root directory of the install, while
        % the envVal will be a sub dir of it.  Use findstr to just match on the
        % shorter string.
        for i=1:length(vsInfo)
            if (vsInfo(i).uniqueFile &&...
                ~isempty(findstr(vsInfo(i).envVal,DSLoc)))
                msvcver = vsInfo(i);
                return;
            end
        end
    end
    
    % next check to see if mexopts specified a version--------------------
    if ~isempty(mexOpts)
        for i=1:length(vsInfo)
            if (vsInfo(i).uniqueFile &&...
                strcmp(mexOpts.msvcver,vsInfo(i).hunVer))
                msvcver = vsInfo(i);
                return;
            end    
        end
    end
    
    % Check the env vars last---------------------------------------------
    for i=1:length(vsInfo)
        if (vsInfo(i).uniqueFile && ~isempty(vsInfo(i).envVal))
            msvcver = vsInfo(i);
            return;
        end
    end    
    
    % if a compiler version has not been identified at this point, it means that
    % there is no BaT specification(DEVSTUDIO_LOC), the mexopts file doesn't
    % exist (from mex -setup), and the env vars for the compiler don't exist.
    % There is no way to continue form this so throw an error.
    DAStudio.error('RTW:buildProcess:missingMSVCEnvironment',...
                   sprintf('%s\n',vsInfo(:).envVar));
    
    return;
    %End of Function locGetMSVCVer

%=============================================================================
% Function: locGetMSVCVer 
%
% inputs:
%
%
% returns:
%    msvcver
%
%
%=============================================================================
function msvcver = locGetMSVCVerInfo()

    msvcver = [];
    idx = 0;

    % the list of supported versions should be put in preference order, from
    % highest preference to lowest preference.  This is what the default
    % compiler version will be if the user has not set one with mex -setup.
    
   % MSVC 9.0
    idx = idx + 1;
    msvcver(idx).hunVer     = '900';
    msvcver(idx).onesVer    = '9.0';
    msvcver(idx).envVar     = 'VS90COMNTOOLS';
    msvcver(idx).envVal     = getenv(msvcver(idx).envVar);
    msvcver(idx).vcvars     = ['"%' msvcver(idx).envVar '%..\..\VC\vcvarsall" AMD64'];
    msvcver(idx).mexopts    = '"$(MATLAB_BIN)\win64\mexopts\msvc90opts.bat"';
    msvcver(idx).uniqueFile = (exist(fullfile(msvcver(idx).envVal,...
                                             '..\IDE\MSTest.exe'),...
                                    'file') == 2);    
    
    %MSVC 8.0
    idx = idx + 1;
    msvcver(idx).hunVer     = '800';
    msvcver(idx).onesVer    = '8.0';
    msvcver(idx).envVar     = 'VS80COMNTOOLS';
    msvcver(idx).envVal     = getenv(msvcver(idx).envVar);
    msvcver(idx).vcvars     = ['"%' msvcver(idx).envVar '%..\..\VC\vcvarsall" AMD64'];
    msvcver(idx).mexopts    = '"$(MATLAB_BIN)\win64\mexopts\msvc80opts.bat"';
    msvcver(idx).uniqueFile = (exist(fullfile(msvcver(idx).envVal,...
                                              'bin\mt.exe'),...
                                     'file') == 2);    
    
        
    % MSVC 9.0 express
    idx = idx + 1;
    msvcver(idx).hunVer     = '900';
    msvcver(idx).onesVer    = '9.0';
    msvcver(idx).envVar     = 'VS90COMNTOOLS';
    msvcver(idx).envVal     = getenv(msvcver(idx).envVar);
    msvcver(idx).vcvars     = ['"%' msvcver(idx).envVar '%..\..\VC\bin\vcvars64"'];
    msvcver(idx).mexopts    = '"$(MATLAB_BIN)\win64\mexopts\msvc90opts.bat"';
    msvcver(idx).uniqueFile = (exist(fullfile(msvcver(idx).envVal,...
                                             '..\IDE\VCExpress.exe'),...
                                    'file') == 2);    
    
    return;
    %End of Function locSetMSVCVer

    
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
function [oString, msvcver] = LocNewSetup(args)

  msvcver.mexopts = ['"$(MATLAB_BIN)\$(ML_ARCH)\mexopts\'...
                     args.mexOpts.originalMexOpts '.bat"'];
  msvcver.onesVer = args.mexOpts.comp.Version;

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

