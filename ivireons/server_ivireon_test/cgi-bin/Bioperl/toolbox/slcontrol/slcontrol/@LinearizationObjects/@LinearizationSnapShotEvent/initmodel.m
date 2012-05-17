function initdata = initmodel(this)
% INITMODEL Initialize the model for the snapshot

%  Author(s): John Glass
%   Copyright 2003-2010 The MathWorks, Inc.
% $Revision: 1.1.8.13.2.1 $ $Date: 2010/07/26 15:40:21 $

% Don't let sparse math re-order columns
autommd_orig = spparms('autommd');
spparms('autommd', 0);

% Load model, save old settings, install new ones suitable for
% linearization and to get the operating points.
[ConfigSetParameters,ModelParams] = createLinearizationParams(linutil,true,true,this.LinData.io,[],this.LinData.opt);
ModelParams.SimulationMode = 'normal';
  
% Find the delay blocks that may need to be replaced
LinData = this.LinData;
% Tell the model which blocks to remove
if ~isempty(LinData.BlockSubs)
    BlocksToRemove = {LinData.BlockSubs.Name};
    ModelParams.SCDLinearizationBlocksToRemove = BlocksToRemove(:);
end
    
% Set the model linearization IOs
this.ModelParameterMgr.LinearizationIO = this.LinData.io;
this.ModelParameterMgr.ModelParameters = ModelParams;
this.ModelParameterMgr.ConfigSetParameters = ConfigSetParameters;
this.ModelParameterMgr.prepareModels('linearization');
initdata = struct('autommd_orig', autommd_orig);
