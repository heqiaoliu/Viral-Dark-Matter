% Function: CleanupForExit ====================================================
% Abstract:
%	- Restore state of the lock and dirty flags
%       - Restore working directory
%       - Leave the attic clean

%   Copyright 2002-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.17 $  $Date: 2010/04/21 21:36:53 $

function CleanupForExit(h,clearBuildInProgress,varargin)

% Unlock active configuration set & simprm dialog
  configSet = getActiveConfigSet(h.ModelName);
  unlock(configSet);
  hDlg = get_param(h.ModelName, 'SimPrmDialog');
  if (~isempty(hDlg) && isa(hDlg, 'DAStudio.Dialog'))
    refresh(hDlg);
  end

  % clean up restorable settings
  cleanRestore(h);
  
  %  LogFileManager(h,'flush');
  if ~isempty(h.StartDirToRestore)
    cd(h.StartDirToRestore);
  end

  % restore RTWCodeReuse flag
  rtwprivate('RTWCodeReuse', h.CodeReuse);
  
  % save getSourceSubsystemName when current build is for sub model.
  if ~strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType,'NONE')
      fullname = rtwprivate('rtwattic','getSourceSubsystemName');
  end
  rtwprivate('rtwattic', 'clean');
  % restore getSourceSubsystemName.
  if ~strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType,'NONE')
      rtwprivate('rtwattic','setSourceSubsystemName', fullname);
  end

  rtwprivate('getSTFInfo',[],'clearCache', true);

  % clear the make-settings object since it is only valid during the build.
  set_param(h.modelName, 'MakeRTWSettingsObject',[]);
  
  %restore the recycle state
  recycle(h.OrigRecycleState);

  % restore the original path
  path(h.PathToRestore);

  % refresh code browser so generated code is viewable
  if nargin > 2
      activeCodeObj = getActiveCode(h.modelName);
      if ~isempty(activeCodeObj)  % when activeCodeObj exists
          activeCodeObj.refresh(varargin{1});
      end
  end

  if clearBuildInProgress
      Simulink.fileGenControl('clearBuildInProgress');
  end
  %---------------------------------------------------------------------------
  % THIS MUST GO LAST.
  %
  % the active code object pollutes the STFInfo with a child
  % model's data.  We want to make sure the cache is truly cleared.
  %---------------------------------------------------------------------------
  rtwprivate('getSTFInfo',[],'clearCache', true);

%endfunction CleanupForExit
