function hiliteloop(this,model,loop,mode)
% HILITELOOP - Highlights the blocks in a feedback loop
%
 
% Author(s): John W. Glass 18-Aug-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:43:05 $

%% Clear the last highlighting
set_param(model,'HiliteAncestors','none');

%% Get the blocks in the feedback loop
BlocksInPathByName = loop.LoopConfig.BlocksInPathByName;

%% Set the types
if strcmp(mode,'on')
    %% Define the colors to be consistent with SISOTOOL.
    plant = 'red';

    %% Hilite the blocks in the linearization.
    for ct = 1:length(BlocksInPathByName)
        try
            set_param(BlocksInPathByName{ct},'HiliteAncestors',plant);
        end
    end
    
    %% Bring the model to front
    open_system(model)
end