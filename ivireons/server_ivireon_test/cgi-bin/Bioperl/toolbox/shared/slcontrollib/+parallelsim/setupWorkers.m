function setupWorkers(mdlName,mdlPathDependencies)
% SETUPWORKERS  static package method to initialize workers for parallel
% simulations
%
% parallelsim.setupWorkers(mdlName,mdlPathDependencies)
%
% Inputs:
%   mdlName - string with the model that is to be loaded on the parallel
%             workers
%   mdlPathDependencies - cell array of strings with the paths that are to
%                         be added to the parallel workers, note that this 
%                         function does not convert the paths to UNC or ensure 
%                         that the paths are available from all workers.
%
% Notes:
%   1) The setup code is run on each worker in the matlabpool.
%   2) The setup will load the specified model on the workers. The model is
%   loaded from disk and it may not match the currently loaded model on the 
%   host if the host model has not been recently saved.
%   3) The setup will cd the workers to worker unique directories so that 
%   when models are run they can write compiled code etc. to a local directory.
%   4) The setup disables Simulink model autosave on the workers.
%   5) See parallelsim.cleanupWorkers for the corresponding clean up code that 
%   restores settings on the workers.
%
 
% Author(s): A. Stothert 11-Mar-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/09/15 20:47:04 $

nWorkers = matlabpool('size');
parfor ct = 1:nWorkers
   localSetupWorker(mdlName,mdlPathDependencies);
end

end

%% Setup function called on each worker
function localSetupWorker(model,dirs)

%Create worker object
simWorker        = parallelsim.simulationTask;
simWorker.model  = model;
simWorker.paths  = dirs;

%Disable path warnings
[lWarnMsg,lWarnID] = lastwarn;
wState(1) = warning('off','MATLAB:dispatcher:pathWarning');
   
%Create temporary directory for model compilation
dirName = tempname;
if ~exist(dirName,'dir')
   parentDir = tempdir;
   mkdir(parentDir,dirName(length(parentDir+1):end))
end
simWorker.uniqueDir = dirName;

%Add dependent directories to path
if ~isempty(simWorker.paths)
   addpath(simWorker.paths{:})
end

%Disable autosave
autosave_status = get_param(0,'AutoSaveOptions');
set_param(0,'AutoSaveOptions',struct('SaveOnModelUpdate',false))

%Do we need to open the model
models = find_system('type','block_diagram');
simWorker.origModels = models;
if ~any(strcmp(models,model))
   load_system(model)
end

%Switch to a unique directory for compilation, cache original
%directory and add to path
strPath = path;
simWorker.origDir = struct(...
   'dir',pwd, ...
   'onPath', ~isempty(strfind(strPath,sprintf('%s;',pwd))));
addpath(simWorker.origDir.dir)
cd(simWorker.uniqueDir)

%Write variables to base workspace for reuse
assignin('base','simWorker',simWorker)
assignin('base','autosave_status',autosave_status);

%Enable warnings
warning(wState); %#ok<WNTAG>
lastwarn(lWarnMsg,lWarnID)
end