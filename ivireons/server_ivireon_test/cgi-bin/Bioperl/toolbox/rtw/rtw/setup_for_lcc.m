function makeCmdOut = setup_for_lcc(args)
%
% Function: SetupForLcc ========================================================
% Abstract:
%       Configure the build process for Lcc
%
%       This function wraps the raw make command, args.makeCmd (e.g. 'gmake -f
%       model.mk MAT_FILE=1') in a batch (.bat) file that sets up some
%       environment variables needed during the build process.
%

% Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.11 $  $Date: 2008/05/19 23:31:34 $
  
  makeCmd        = args.makeCmd;
  modelName      = args.modelName;
  verbose        = args.verbose;
  
  % args.compilerEnvVal not used

  specified_via_makeCmd = false;
  lcc_root = parsestrforvar(makeCmd,'LCC_LOC');
  if isempty(lcc_root)
    lcc_root = [matlabroot '\sys\lcc'];
  else
    specified_via_makeCmd = true;
  end

  if ~isempty(lcc_root)
    if isempty(dir([lcc_root,'\bin\lcc.exe']))
        DAStudio.error('RTW:compilerConfig:compilerNotFound',...
                            'LCC',lcc_root,'LCC');
    end
    
    % this may be a non-model based build.  If so, then the make settings
    % object will not exist.  The mexopts file can be left blank here, as
    % buildInfo will have it set appropriately.
    if (RTW.areModelsOpen(modelName))
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
            makeRTWObj.InstallDirmexopts = '$(MATLAB_BIN)\win32\mexopts\lccopts.bat';
            % if the BuildInfo Object InstallDirmexopts is empty, then we need to
            % update it.
            if isempty(makeRTWObj.BuildInfo.InstallDirmexopts)
                makeRTWObj.BuildInfo.InstallDirmexopts =...
                    makeRTWObj.InstallDirmexopts;
            end
            if ~specified_via_makeCmd
                makeRTWObj.CompilerName = '_lcc.tmf';
            else
                makeRTWObj.CompilerName = 'MAKECMD_lcc.tmf';
            end
        end
    end
    
    cmdFile = ['.\',modelName, '.bat'];
    cmdFileFid = fopen(cmdFile,'wt');
    if ~verbose
      fprintf(cmdFileFid, '@echo off\n');
    end
    fprintf(cmdFileFid, 'set MATLAB=%s\n', matlabroot);
    fprintf(cmdFileFid, '%s\n', makeCmd );
    fclose(cmdFileFid);
    makeCmdOut = cmdFile;
  else
    if isempty(lcc_root)
        DAStudio.error('RTW:compilerConfig:compilerNotFound',...
                       'LCC',lcc_root,'LCC');
    end
    makeCmdOut = makeCmd;  % No change
  end

%endfunction setup_for_lcc
