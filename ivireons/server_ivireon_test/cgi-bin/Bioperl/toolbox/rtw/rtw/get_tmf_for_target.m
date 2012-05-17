function [tmf,envVal,mexOpts] = get_tmf_for_target(target)
%GET_TMF_FOR_TARGET Returns the default template makefile on for given target
%
%       On Unix systems, the default template makefile is <target>_unix.tmf.
%       On PC systems, the default template makefile is determined by
%       examining mexopts.bat (see help mex). It will be <target>_watc.tmf
%	if WATCOM exists in mexopts.bat, <target>_bc.tmf if BORLAND exists
%	in mexopts.bat, otherwise <target>_vc.tmf.

%       Copyright 1994-2010 The MathWorks, Inc.
%       $Revision: 1.17.2.12.4.1 $


  envVal = ''; % Will be non-empty if we learned of the environment variable
               % from the mexopts preference file on the PC

  prefDirInvalid = false;
  
  mexOpts = [];
  if isunix
      suffix = '_unix.tmf';
  else

      comp = rtwprivate('rtwParallelBuildCompiler','get');

      % if no parallel compiler was set, revert to checking mexopts.bat
      if isempty(comp)

          rc = rtwprivate('getMexCompilerInfo');
          if strcmp(computer,'PCWIN64')
              newCompSupport = {'Microsoft-10.0',...
                                'Microsoft-10.0exp',...
                                'Microsoft-9.0exp'};
          else
              newCompSupport = {'Microsoft-10.0',...
                               'Microsoft-10.0exp'};
          end
          
          if (~isempty(rc) && ismember(rc.compStr,newCompSupport))
              tmf = [target, rc.suffix];
              mexOpts = rc;
              return;
          end
          
          [envVal, suffix, mexOpts] = parse_mexopts_for_envval('');
          % the mexOpts arg must have a compStr field to check for the new style
          % compiler support.  Just add a dummy value for the traditional
          % support.
          mexOpts.compStr = 'Traditional Support';
          
          
          % as MSVC8 is supported on both win32 and win64, we can't use
          % mexopts.bat to distinguish them. Therefore, we need following logic.
          if strcmp(computer,'PCWIN64')
              if ~strcmp(suffix, '_vc.tmf')
                  prefDirInvalid = true;
              end
              if (~isempty(getenv('VS80COMNTOOLS')) ||...
                  ~isempty(getenv('VS90COMNTOOLS')))
                  suffix = '_vcx64.tmf';
              else
                  suffix = '_vcx64.tmf';
                  envVal = 'no default compiler';
              end
          end
      else
          % A parallel build compiler was selected, so it should be used.
          suffix = comp.suffix;
      end
      
      if isempty(suffix)
          prefDirInvalid = true;
          switch(computer)
            case 'PCWIN'
              if ~isempty(getenv('VS90COMNTOOLS')) ||...
                      ~isempty(getenv('VS80COMNTOOLS')) ||...
                      ~isempty(getenv('DEVSTUDIO')) ||...
                      ~isempty(getenv('MSDevDir')) ||...
                      ~isempty(getenv('MSVCDir'))
                  suffix = '_vc.tmf';
              elseif (exist([matlabroot '\sys\lcc']))
                  suffix = '_lcc.tmf';
              else
                  suffix = '_lcc.tmf'; 
                  envVal = 'no default compiler';
              end
          end
      end
  end
  
  % save the prefdir mexopts analyze result into MakeRTWSettingsObject to
  % avoid duplicate analyzing.
  modelName = bdroot;
  if ~isempty(modelName)
      makeRTWObj=get_param(modelName,'MakeRTWSettingsObject');
      if ~isempty(makeRTWObj)
          if ~prefDirInvalid
              makeRTWObj.PreferredTMF = suffix;
          else
              makeRTWObj.PreferredTMF = 'unknown';
          end
      end
  end
      
  tmf = [target, suffix];
  
%endfunction get_tmf_for_target

%[EOF] get_tmf_for_target.m

% LocalWords:  mexopts watc bc BORLAND vc PCWIN COMNTOOLS vcx DEVSTUDIO lcc
