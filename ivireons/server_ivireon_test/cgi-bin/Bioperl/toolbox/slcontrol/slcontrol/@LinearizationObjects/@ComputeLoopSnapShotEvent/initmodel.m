function initdata = initmodel(this)
% INITMODEL Initialize the model for the snapshot

%  Author(s): John Glass
%   Copyright 2003-2010 The MathWorks, Inc.
% $Revision: 1.1.8.12.2.1 $ $Date: 2010/07/26 15:40:19 $

% Don't let sparse math re-order columns
autommd_orig = spparms('autommd');
spparms('autommd', 0);

% Load model, save old settings, install new ones suitable for
% linearization and to get the operating points.
[ConfigSetParameters,ModelParams] = createLinearizationParams(linutil,true,true,this.IOSettings.IOUnique,[],this.linopts,true);
ModelParams.SimulationMode = 'normal';
ModelParams.SCDLinearizationBlocksToRemove = get(this.TunedBlocks,{'Name'});

% Now that we have the IOs, compute the Jacobian for all combinations.
this.ModelParameterMgr.LinearizationIO = this.IOSettings.IOUnique;
this.ModelParameterMgr.ModelParameters = ModelParams;
this.ModelParameterMgr.ConfigSetParameters = ConfigSetParameters;
this.ModelParameterMgr.prepareModels('linearization');
initdata = struct('autommd_orig', autommd_orig);
