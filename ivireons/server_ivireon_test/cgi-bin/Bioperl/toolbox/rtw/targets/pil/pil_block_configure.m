function silPILBlock = pil_block_configure(block, ...
                                           componentPath, ...
                                           codeDir, ...
                                           isSILMode, ... 
                                           topModelPILWrapperModel)
% PIL_BLOCK_CONFIGURE - Configure a SIL/PIL block
%
% block - handle to the SIL/PIL block to configure or empty to create a new
%         SIL/PIL block in a new model
%
% componentPath - Simulink component path
%
% codeDir - Generated code directory
%                       
% isSILMode - boolean indicating whether to create a SIL or PIL block
%

% Copyright 2005-2010 The MathWorks, Inc.

error(nargchk(4, 5, nargin, 'struct'));

if nargin<5
    topModelPILWrapperModel = [];
    isTopModelPIL = false;
    isTopModelPILParam = 'off';
else
    isTopModelPIL = true;
    isTopModelPILParam = 'on';
end

if isSILMode
    simulationMode = 'SIL';
else
    simulationMode = 'PIL';
end

if ~isTopModelPIL
    disp(['### Creating ' simulationMode ' block ...']);    
end

[rootModel, systemPath] = strtok(componentPath, '/');
assert(bdIsLoaded(rootModel), 'Model "%s" must be loaded', rootModel);

% reapply (for top-model PIL block) same validation
% as is applied from build_pil_target.m for Top-Model PIL
if ~isTopModelPIL    
    if isempty(systemPath)
        rtw.pil.PILBlockSfunction.sharedValidation(rootModel);
    end
end

% reapply (for top-model & subsys PIL block) same validation 
% as is applied from build_pil_target.m for Top-Model PIL
if ~isTopModelPIL
    rtw.pil.AutosarTargetInterface.sharedValidation(componentPath);            
end

% Create the PIL block if required
if isempty(block)
    % create a new system
    if isempty(topModelPILWrapperModel)
        h = new_system;
    else
        h = new_system(topModelPILWrapperModel);
    end        
    % Don't make the model containing the PIL block visible for Top Model
    % PIL                            
    if ~isTopModelPIL        
        open_system(h);
    end
    % add a new PIL Block
    pilLib = 'pil_lib';
    pilLibBlock = [pilLib '/PIL Block'];
    if isSILMode
        targetBlockName = 'SIL Block';
    else
        targetBlockName = 'PIL Block';
    end    
    load_system(pilLib);
    % lock down "Position" explicitly
    block = add_block(pilLibBlock, ...
                      [get_param(h, 'Name') '/' targetBlockName], ...
                      'Position', [15 15 100 70]);
end

% set SimulationMode
set_param(block, 'SimulationMode', simulationMode);

% set the block name according to the component path
% if it is valid
try
    load_system(rootModel);
    find_system(componentPath, 'SearchDepth', 0);
    fullSystemPathValid = true;
catch exc
    if strcmp(exc.identifier, 'Simulink:Commands:FindSystemInvalidPVPair') || ...
            strcmp(exc.identifier, 'Simulink:Commands:OpenSystemUnknownSystem')
        fullSystemPathValid = false;
    else
        rethrow(exc)
    end
end
if fullSystemPathValid
    % set the name of the PIL block
    set_param(block, 'Name', ...
        get_param(componentPath, 'Name'));
end

% set Top Model PIL flag
set_param(block, 'IsTopModelPIL', isTopModelPILParam);
% set the CodeDir
set_param(block, 'CodeDir', codeDir);
% find the connectivity config that is valid for this
% component
%
% Note: there is 1 PIL application per PIL component, therefore
% all instances of the same component use the same config
if isSILMode
    config = rtw.pil.ModelBlockPIL.getSilConnectivityConfig(rootModel);
else
    config = rtw.pil.ModelBlockPIL.getPilConnectivityConfig...
        (rootModel);
end
% cache config on the block
set_param(block, 'ConfigName', config.ConfigName);

% create an instance of the pil dialog class
silPILBlock = rtw.pil.SILPILBlock(get_param(block, 'handle'));
displayConfigHyperlink = ~isTopModelPIL && ~isSILMode;
pilInterface = silPILBlock.getPILInterface(displayConfigHyperlink);
% bring the wrapper up to date
pilInterface.buildWrapper;
% initialize the block
silPILBlock.blockInit(pilInterface);

% Resize the Simulink block according to the System Path of
% the PIL Interface object
%
% if the systemPath is empty, the PIL component is a root model
% so we can't resize it
if ~isempty(systemPath) && fullSystemPathValid
    % determine the size and orientation of the PIL component block
    pilAlgPos = get_param(componentPath, 'Position');
    pilAlgWidth = pilAlgPos(3) - pilAlgPos(1);
    pilAlgHeight = pilAlgPos(4) - pilAlgPos(2);
    pilAlgOrientation = get_param(componentPath, 'Orientation');
    % determine the position of the PIL Block
    pilBlockPos = get_param(block, 'Position');
    pilBlockX = pilBlockPos(1);
    pilBlockY = pilBlockPos(2);
    blockPosition = [pilBlockX, pilBlockY, ...
        pilBlockX + pilAlgWidth, ...
        pilBlockY + pilAlgHeight];
    blockOrientation = pilAlgOrientation;
    set_param(block, 'Position', blockPosition);
    set_param(block, 'Orientation', blockOrientation);
end
