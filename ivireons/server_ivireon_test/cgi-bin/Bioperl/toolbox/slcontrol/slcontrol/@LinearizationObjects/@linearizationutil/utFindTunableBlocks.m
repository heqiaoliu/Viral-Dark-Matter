function [blockdata,hierarchy] = utFindTunableBlocks(this,ModelParameterMgr)
% UTFINDTUNABLEBLOCKS  Find the blocks that can be tuned in Simulink
% Control Design.
%
 
% Author(s): John W. Glass 18-Jul-2005
%   Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.8.11 $ $Date: 2010/04/11 20:41:04 $

% Get parent model and all of the referenced models
models = ModelParameterMgr.getUniqueNormalModeModels;

% Create the block config utility object
blockconfig = LinearizationObjects.blockconfig;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Masked Subsystems with User Defined Inverse Functions 

% Find the blocks with InvertFcns
inv_blks = regexprep(find_system(models,'regexp','on','SCDConfigFcn','.*'),'\n',' ');
% Next find the block data with SISO channels
blockdata = LocalFindSISOChannels(inv_blks);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Built in blocks
BuiltInBlocks = {'Gain',{@GainBlock,blockconfig};...
                 'TransferFcn',{@CTransferFcn,blockconfig};...
                 'StateSpace',{@CStateSpace,blockconfig};...
                 'ZeroPole',{@CZPK,blockconfig};...
                 'DiscreteTransferFcn',{@DTransferFcn,blockconfig};...
                 'DiscreteFilter',{@DFilterFcn,blockconfig};...
                 'DiscreteZeroPole',{@DZPK,blockconfig};...
                 'DiscreteStateSpace',{@DStateSpace,blockconfig}};
             
for ct = 1:size(BuiltInBlocks,1)
    % Find the gains that are tunable
    blks = regexprep(find_system(models,'BlockType',BuiltInBlocks{ct,1}),'\n',' ');
    % Next find the block data with SISO channels
    blockdata = [blockdata;LocalFindSISOChannels(blks,BuiltInBlocks{ct,2})];
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulink SubSystems

% Find the masked subsystems with library links
maskedSS = regexprep(find_system(models,'BlockType','SubSystem','Mask','on',...
                           'LinkStatus','resolved'),'\n',' ');
% Find the masked subsystem library links
refblkSS = regexprep(get_param(maskedSS,'ReferenceBlock'),'\n',' ');

MaskedBlocks = {'simulink_need_slupdate/PID Controller (with Approximate Derivative)',{@PIDApproxBlock,blockconfig};...
                'simulink_need_slupdate/PID Controller',{@PIDBlock,blockconfig};...
                'simulink/Continuous/PID Controller',{@PIDBlock1dof,blockconfig};...
                'simulink/Discrete/Transfer Fcn First Order',{@DTFFirstOrder,blockconfig};...
                'simulink/Discrete/Transfer Fcn Lead or Lag',{@DTFLeadLag,blockconfig};...
                'simulink/Discrete/Transfer Fcn Real Zero',{@DTFRealZero,blockconfig};...
                'cstblocks/LTI System',{@LTIBlock,blockconfig};...
                'simulink_extras/Additional Linear/Transfer Fcn (with initial states)',{@CTransferFcnIC,blockconfig};...
                'simulink_extras/Additional Linear/Transfer Fcn (with initial outputs)',{@CTransferFcnIO,blockconfig};...
                'simulink_extras/Additional Discrete/Discrete Transfer Fcn (with initial states)',{@DTransferFcnIC,blockconfig};...
                'simulink_extras/Additional Discrete/Discrete Transfer Fcn (with initial outputs)',{@DTransferFcnIO,blockconfig};...
                'simulink_extras/Additional Linear/Zero-Pole (with initial states)',{@CZPKIC,blockconfig};...
                'simulink_extras/Additional Linear/Zero-Pole (with initial outputs)',{@CZPKIO,blockconfig};...
                'simulink_extras/Additional Discrete/Discrete Zero-Pole (with initial states)',{@DZPKIC,blockconfig};...
                'simulink_extras/Additional Discrete/Discrete Zero-Pole (with initial outputs)',{@DZPKIO,blockconfig};...
                'simulink_extras/Additional Linear/State-Space (with initial outputs)',{@CStateSpaceIO,blockconfig};...
                'discretizing/Discretized State-Space',{@MDStateSpace,blockconfig};...
                'discretizing/Discretized Transfer Fcn',{@MDTransferFcn,blockconfig};...
                'discretizing/Discretized Zero-Pole',{@MDZPK,blockconfig};...
                'discretizing/Discretized Transfer Fcn (with initial states)',{@MDTransferFcnIC,blockconfig};...
                'discretizing/Discretized LTI System',{@MDLTIBlock,blockconfig};};
            
for ct = 1:size(MaskedBlocks,1)
    blks = maskedSS(strcmp(refblkSS,MaskedBlocks{ct,1}));
    % Next find the block data with SISO channels
    blockdata = [blockdata;LocalFindSISOChannels(blks,MaskedBlocks{ct,2})];
end

% Convert the cell data to a struct
blockdata = cell2struct(blockdata,{'block','blockfcn'},2);

% Find the model hierarchy for the blocks
hierarchy = utBuildTunableBlockHierarchy(this,ModelParameterMgr,{blockdata.block});

%% LOCALFINDSISOCHANNELS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over each block to determine the valid I/O ports.  These ports
% should have a compiled width of 1
function blockdata = LocalFindSISOChannels(blks,varargin)

% Initialize the data cell array
blockdata = cell(0,2);

% Loop over the potential blocks
for ct = length(blks):-1:1
    % Get the compiled port dimensions
    port_dim = get_param(blks{ct},'CompiledPortDimensions');
    % Get the compiled sample time
    ts_blk = get_param(blks{ct},'CompiledSampleTime');
    % Find the ports that have scalar signals
    valid_inports = find(port_dim.Inport(2:length(port_dim.Inport))==1, 1);
    valid_outports = find(port_dim.Outport(2:length(port_dim.Outport))==1, 1);
    % If there is at least 1 inport and 1 outport then this block is valid
    if ~isempty(valid_inports) && ~isempty(valid_outports) && (ts_blk(1) ~= -1)
        % If a configuration function is specified use it.  Otherwise
        % query from the block.
        if nargin == 2
            blockfcn = varargin{1};
        else
            blockfcn = {get_param(blks{ct},'SCDConfigFcn')};
        end
        blockdata(end+1,:) = {blks{ct},blockfcn};
    end        
end
