function [loopdata,op] = computeloopdata(this,mdl,ClosedLoopIO,TunedBlocks,op,opt,LoopIO)
% COMPUTELOOPDATA  Compute the loopdata object from configurations given in
% the configuration wizard
%

% Author(s): John W. Glass 08-Aug-2005
% Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.8.21.2.1 $ $Date: 2010/07/26 15:40:23 $

% Create the model parameter manager
ModelParameterMgr = linearize.ModelLinearizationParamMgr.getInstance(mdl);
ModelParameterMgr.loadModels;

% Set the sample time of the current design
for ct = numel(TunedBlocks):-1:1
   TunedBlocks(ct).Ts = opt.SampleTime;
end

% Make sure the each feedback has the remaining loops as potential loop
% openings.
fbLoopIO = [LoopIO.FeedbackLoop];
LoopOpenings = [];
for ct = 1:numel(LoopIO)
   LoopOpenings = [LoopOpenings;LoopIO(ct).LoopOpenings(:)];
end

% Now that we have the IOs, compute the Jacobian for all combinations.
allios = [fbLoopIO(:);ClosedLoopIO(:);LoopOpenings(:)];
IOUnique = utFindJacobianMultIOs(this,allios);
IOSettings = struct('ClosedLoopIO',ClosedLoopIO,'LoopIO',LoopIO,'IOUnique',IOUnique);
iospec = linearize.createIOSpecStructure(IOUnique);

if isa(op,'double')
   % Get the snapshot times and create the snapshot object
   evt = LinearizationObjects.ComputeLoopSnapShotEvent(ModelParameterMgr,op);
   evt.linopts = opt;
   evt.IOSettings = IOSettings;
   evt.TunedBlocks = TunedBlocks;
   evt.IOSpec = iospec;
   
   % Run the snapshot
   try
      Data = evt.runsnapshot;
   catch SnapshotError
      ModelParameterMgr.closeModels
      throwAsCaller(SnapshotError);
   end
   op = [Data.OperatingPoint];
   loopdata = [Data.loopdata];
   ModelParameterMgr.closeModels
else
   % Parameter settings we need to set/cache before linearizing
   if numel(op.Inputs)
      useModelu = false;
   else
      useModelu = true;
   end
   [ConfigSetParameters,ModelParams] = createLinearizationParams(this,false,useModelu,IOUnique,op.Time,opt);
   ModelParams.SimulationMode = 'normal';
   ModelParams.SCDLinearizationBlocksToRemove = get(TunedBlocks,{'Name'});
   ModelParameterMgr.LinearizationIO = IOUnique;
   ModelParameterMgr.ModelParameters = ModelParams;
   ModelParameterMgr.ConfigSetParameters = ConfigSetParameters;
   ModelParameterMgr.prepareModels('linearization');
   
   % Now compile the model
   ModelParameterMgr.compile('lincompile');
   
   % Now push the operating point onto the model
   try
      utPushOperatingPoint(linutil,mdl,op,linoptions)
      J = getJacobian(linutil,mdl,iospec);
      loopdata = utJacobian2LoopData(this,ModelParameterMgr,J,IOSettings,TunedBlocks,opt);
   catch ComputeLoopsException
      % Clean up
      ModelCleanUp(ModelParameterMgr)
      throwAsCaller(ComputeLoopsException);
   end
   % Clean up
   ModelCleanUp(ModelParameterMgr)
end

% Initialize the loopviews
for ct = 1:numel(loopdata)
   localUpdateViews(loopdata(ct))
end

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ModelCleanUp(ModelParameterMgr)
%  Terminate the compilation of the model
if strcmp(get_param(ModelParameterMgr.Model,'SimulationStatus'),'paused')
   ModelParameterMgr.term;
end
ModelParameterMgr.restoreModels;
ModelParameterMgr.closeModels;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localUpdateViews(loopdata)

% UDDREVISIT: private static
innames = loopdata.Input;
outnames = loopdata.Output;

ColorStyle = {'b', 'g', 'r', 'c', 'm', 'y', ...
   'b--', 'g--', 'r--', 'c--', 'm--', 'y--', ...
   'b-.', 'g-.', 'r-.', 'c-.', 'm-.', 'y-.', ...
   'b^', 'g^', 'r^', 'c^', 'm^', 'y^'};

%% Create the maximum 4 Closed Loops
nin = numel(innames);
nout = numel(outnames);
nCl = min(4,nin*nout);
for ct = 1:nCl
   LoopTF(ct,1) = sisodata.looptransfer;
end

if nin > 1 && nout >1
   for ct1 = 1:2
      for ct2 = 1:2
         loopn = 2*ct1+ct2-2;
         LoopTF(loopn,1) = sisodata.looptransfer;
         Description = sprintf('Closed Loop from %s to %s',innames{ct1},outnames{ct2});
         LoopTF(loopn,1).Description = Description;
         LoopTF(loopn,1).Index = {ct2 ct1};
         LoopTF(loopn,1).ExportAs = sprintf('T_%d',ct);
         LoopTF(loopn,1).Type = 'T';
         LoopTF(loopn,1).Style = ColorStyle{mod(loopn-1,length(ColorStyle))+1};
      end
   end
elseif nin == 1
   for ct = 1:nCl
      LoopTF(ct,1) = sisodata.looptransfer;
      Description = sprintf('Closed Loop from %s to %s',innames{1},outnames{ct});
      LoopTF(ct,1).Description = Description;
      LoopTF(ct,1).Index = {ct 1};
      LoopTF(ct,1).ExportAs = sprintf('T_%d',ct);
      LoopTF(ct,1).Type = 'T';
      LoopTF(ct,1).Style = ColorStyle{mod(ct-1,length(ColorStyle))+1};
   end
else
   for ct = 1:nCl
      LoopTF(ct,1) = sisodata.looptransfer;
      Description = sprintf('Closed Loop from %s to %s',innames{ct},outnames{1});
      LoopTF(ct,1).Description = Description;
      LoopTF(ct,1).Index = {1 ct};
      LoopTF(ct,1).ExportAs = sprintf('T_%d',ct);
      LoopTF(ct,1).Type = 'T';
      LoopTF(ct,1).Style = ColorStyle{mod(ct-1,length(ColorStyle))+1};
   end
end

loopdata.LoopView=LoopTF;
end
