function makeCmdOut = setup_for_watcom(args)
%
% Function: SetupForWatcom =====================================================
% Abstract:
%       Configure the build process for Watcom
%  
%       This function wraps the raw make command, args.makeCmd (e.g. 'wcmake -f
%       model.mk MAT_FILE=1') in a batch (.bat) file that sets up some
%       environment variables needed during the build process.
%

% Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.17 $  $Date: 2009/10/24 19:21:25 $

  makeCmd        = args.makeCmd;
  modelName      = args.modelName;
  verbose        = args.verbose;
  compilerEnvVal = args.compilerEnvVal;

  watcom = parsestrforvar(makeCmd,'WATCOM_LOC');
  if isempty(watcom)
    specified_via_makeCmd = false;
    if isempty(compilerEnvVal)
      compilerEnvVal=parse_mexopts_for_envval('_watc.tmf');
    end
    if ~isempty(compilerEnvVal)
      watcom = compilerEnvVal;
    else
      watcom = getenv('WATCOM');
    end
  else
    specified_via_makeCmd = true;
  end

  if ~isempty(watcom)
    if isempty(dir([watcom,'\binnt\wmake.exe']))
      checkEnvVal='  %WATCOM%\binnt\wmake.exe';
      issue_inv_comp_env_val_error('WATCOM',watcom, checkEnvVal, ...
                              '  set WATCOM=<WatcomPath>');
    end
    [status,result]=dos([watcom,'\binnt\wmake /?']);
    
    watver = '';
    add_Option = '';

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
            
            if ~specified_via_makeCmd
                makeRTWObj.CompilerName = '_watc.tmf';
            else
                makeRTWObj.CompilerName = 'MAKCMD_watc.tmf';
            end
            cur_ver = '1.8';
            if ~isempty(findstr(result,['Open Watcom Make Version ' cur_ver]))
                watver = [' WATCOM_VER=' cur_ver];
                makeRTWObj.InstallDirmexopts =...
                    '$(MATLAB_BIN)\win32\mexopts\openwatcopts.bat';
            else
                if ~isempty(findstr(result,'Open Watcom'))
                    DAStudio.warning('RTW:compilerConfig:watcomVersionWarning',cur_ver);
                    watver = [' WATCOM_VER=' cur_ver];
                    makeRTWObj.InstallDirmexopts =...
                        '$(MATLAB_BIN)\win32\mexopts\openwatcopts.bat';
                else
                    DAStudio.error('RTW:compilerConfig:watcomVersionError',result);
                end
            end

            % if the BuildInfo Object InstallDirmexopts is empty, then we
            % need to update it.
            if isempty(makeRTWObj.BuildInfo.InstallDirmexopts)
                makeRTWObj.BuildInfo.InstallDirmexopts =...
                    makeRTWObj.InstallDirmexopts;
            end
        end
    end
    
    cmdFile = ['.\',modelName, '.bat'];
    cmdFileFid = fopen(cmdFile,'wt');
    if ~verbose
      fprintf(cmdFileFid, '@echo off\n');
    end
    fprintf(cmdFileFid, 'set WATCOM=%s\n', watcom);
    % clear the error level just before the make call (any successful command
    % will do it), so that we only show the make errorlevel.
    fprintf(cmdFileFid, 'cd .\n');
    fprintf(cmdFileFid, '%s\n', [makeCmd, watver, add_Option]);
    
    % note that the way errorlevel works in msdos is that if the error level is
    % greater than or equal to the error level checked, it evaluates to true.
    % So the statement 'if errorlevel 1...' will return true if any error has
    % occurred.
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
  else
    if isempty(getenv('WATCOM'))
        DAStudio.error('RTW:compilerConfig:envVariableUndefined',...
                       'WATCOM','Watcom');
    end
    makeCmdOut = makeCmd;  % No change
  end
  
  % Delete the .err file left by a previous Watcom build
  
  errfile = [args.modelName,'.err'];
  
  if ~isempty(dir(errfile))
    rtw_delete_file(errfile);
  end

%endfunction setup_for_watcom

