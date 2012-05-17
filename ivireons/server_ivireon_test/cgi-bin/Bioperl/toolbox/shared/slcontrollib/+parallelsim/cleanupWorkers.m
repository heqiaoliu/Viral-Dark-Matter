function cleanupWorkers
% CLEANUPWORKERS static package method to cleanup workers after parallel
% simulations
%
% parallelsim.cleanupWorkers
%
% Inputs:
%   none
%
% Notes:
%   1) The cleanup code is run on each worker in the matlabpool.
%   2) The restores the workers the state prior to the last
%   parallelsim.setupWorker call.
%   3) See parallelsim.setupWorkers for details of worker setup code.
 
% Author(s): A. Stothert 11-Mar-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/09/15 20:47:03 $

nWorkers = matlabpool('size'); 
parfor ct=1:nWorkers
   localCleanupWorker
end
end

%% Cleanup function called on each worker 
function localCleanupWorker 

baseVars = evalin('base','who');

%Reset autosave status
if any(strcmp(baseVars,'autosave_status'))
   autosave_status = evalin('base','autosave_status');
   set_param(0,'AutoSaveOptions',autosave_status)
   %Clear variable added to workspace
   evalin('base','clear autosave_status')
end

%Remove dependent directories
if any(strcmp(baseVars,'simWorker'))
   simWorker = evalin('base','simWorker');
   
   %Disable path warnings
   [lWarnMsg,lWarnID] = lastwarn;
   wState(1) = warning('off','MATLAB:dispatcher:pathWarning');
   wState(2) = warning('off','MATLAB:rmpath:DirNotFound');
   
   %Return to original directory
   cd(simWorker.origDir.dir)
   if ~simWorker.origDir.onPath
      rmpath(simWorker.origDir.dir)
   end
   
   %Close any models opened 
   newModels = find_system('type','block_diagram');
   closeList = setdiff(newModels,simWorker.origModels);
   for ct = 1:numel(closeList)
       close_system(closeList{ct},0)
   end
  
   %Clean up temporary directory
   if exist(simWorker.uniqueDir,'dir')
      %Unload any mex files from the temp directory that may still be in memory
      files = dir(fullfile(simWorker.uniqueDir,'*mex*'));
      if ~isempty(files)
         clear(files.name)
      end
      rmdir(simWorker.uniqueDir,'s')
   end
   
   %Restore worker path
   if ~isempty(simWorker.paths)
      rmpath(simWorker.paths{:})
   end
   
   %Clear variable added to workspace
   evalin('base','clear simWorker')
   
   %Enable warnings
   warning(wState); %#ok<WNTAG>
   lastwarn(lWarnMsg,lWarnID)
   
end
end

