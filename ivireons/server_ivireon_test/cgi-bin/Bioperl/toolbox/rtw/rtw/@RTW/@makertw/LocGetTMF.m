function LocGetTMF(h, hModel,rtwroot)
% LOCGETTMF:
%     Get the template makefile to be used by the build process
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.14.2.1 $  $Date: 2010/07/12 15:22:39 $

% if this is a non-makefile based build the TemplateMakefile and CompilerEnvVal
% should remain empty.
  if (strcmp(get_param(hModel, 'GenerateMakefile'),'off'))
      return;
  end

  h.TemplateMakefile = deblank(get_param(hModel,'RTWTemplateMakefile'));
  h.ProjectBuild = ismember(h.TemplateMakefile,{'RTW.MSVCBuild'});
  
  if any(strcmpi(h.TemplateMakefile,{'ert_msvc.tmf','grt_msvc.tmf'}))
     fprintf(1, ['Note: The selected template makefile will be removed', ...
     'in a future release\n'])  %#ok<PRTCAL>
  end
  
  compiler = 'vc';
  if ~h.ProjectBuild
      
      [h.TemplateMakefile, h.CompilerEnvVal, h.mexOpts] = ...
          rtwprivate('getTMF',hModel, rtwroot);
      
      
      % get the compiler from the tmf
      tmfContents = rtwprivate('loadTMF',h.TemplateMakefile);
      
      
      compiler = rtwprivate('getTMFMacro',tmfContents,'COMPILER_TOOL_CHAIN');
      
      isSol64 = strcmpi(computer,'sol64');
      if (isempty(compiler) || isSol64)
          if isunix
              compiler = 'unix';
              if(isSol64)
                  % are we using gcc or cc?
                  info = evalc(['system(''',matlabroot,filesep, 'bin',...
                      filesep, 'mex -v'')']);
                  if isempty(strfind(info,'gcc'))
                      compiler = 'unix_cc';
                  end
              end
          else
              makeCmd = rtwprivate('getTMFMacro',tmfContents, 'MAKECMD');
              compiler = rtwprivate('getCompilerFromMakeCmd', makeCmd);
          end
      end
  else
      h.TemplateMakefile = which(h.TemplateMakefile);
  end

  % if this is a sim build - Accel or MdlRef SIM, then get the Sim
  % optimizations, otherwise get the RTW optimizations
  if strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType,'SIM') || ...
          strcmpi(get_param(h.ModelName, 'SystemTargetFile'),'accel.tlc') || ...
          strcmpi(get_param(h.ModelName, 'SystemTargetFile'),'raccel.tlc') 
      optSettings = get_param(h.ModelName, 'SimCompilerOptimization');
      isSimTarget = true;
  else
      optSettings = get_param(h.ModelName, 'RTWCompilerOptimization');
      isSimTarget = false;
  end
  
  % if optSettings is 'Custom', then get the custom options, otherwise look
  % up the compiler specific strings
  if strcmpi(optSettings,'custom')
      opt_opts = get_param(h.ModelName,'RTWCustomCompilerOptimizations');
  else
      opt_opts = rtwprivate('getCompilerSpecificStrings',...
                            lower(compiler),optSettings,isSimTarget);
  end
  
  % if the current configset is optimization level compliant, or this is a
  % sim target, add the flags to BuildInfo.
  if isSimTarget || strcmp(get_param(h.ModelName,'CompOptLevelCompliant'),'on')
      h.BuildInfo.addCompileFlags(opt_opts,'OPTIMIZATION_FLAGS');
  end
  
  
%endfunction LocGetTMF

% LocalWords:  Env msvc tmf grt vc MAKECMD raccel
