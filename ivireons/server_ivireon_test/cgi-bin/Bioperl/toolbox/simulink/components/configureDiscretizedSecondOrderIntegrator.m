function configureDiscretizedSecondOrderIntegrator(block, sIntVariant)
% Configure the discretized Second-Order Integrator
% This is the initialization script for the discretized Second-Order Integrator
% It is called from the mask initialization command
%
% Input Arguments:
%
% block: The discretized subsystem
%
% sIntVariant: Depending on the block parameters, a different discretized
% subsystem variant (and different initialization set up) needs to be used.
% The mask calls this script with its variant type.
% sIntVariant can take the following values:
% xLimited, xLimitedWithReset, xFreeWithReset, xFree

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.2.2.1 $ $Date: 2010/06/24 19:44:46 $

% This initialization script does not anything if the simulation is
% running or simulation is external or simulation is paused
simStatus = get_param(bdroot,'SimulationStatus');

if (strcmp(simStatus, 'running') || strcmp(simStatus, 'external') ...
        || strcmp(simStatus, 'paused') )
    return;
end

% Set the integrator method on the discrete-integrator
IntegratorMethod = get_param(block,'IntegratorMethod');

set_param([block '/x'],'IntegratorMethod', IntegratorMethod);
set_param([block '/dxdt'],'IntegratorMethod', IntegratorMethod);

% Configure the output ports
set_param([block '/dxdt'],'LimitOutput', get_param(block, 'LimitDXDT'));
configureOutports(block);

% Configure external versus internal initial conditions
ICSourceX = get_param(block, 'ICSourceX');
configureInitialConditionSource([block '/x0'], ICSourceX, 'ICX');

ICSourceDXDT = get_param(block, 'ICSourceDXDT');
configureInitialConditionSource([block '/dx0'], ICSourceDXDT, 'ICDXDT');

% Variant specific Handling

% Set the reset type on individual integrators
% Common between xLimitedWithReset and xFreeWithReset
% This is a tentative setting at this stage:
% It will be modified below for limited variants again
if strcmp(sIntVariant, 'xLimitedWithReset') || ...
        strcmp(sIntVariant, 'xFreeWithReset')
    set_param([block '/x'],'ExternalReset',...
        get_param(block,'ExternalReset'));
    set_param([block '/dxdt'],'ExternalReset',...
        get_param(block,'ExternalReset'));
end

% Set the 'Reinitialize dx/dt when x reaches saturation' parameter for
% limited variants
if strcmp(sIntVariant, 'xLimited') || ...
        strcmp(sIntVariant, 'xLimitedWithReset')
        
    set_param([block '/InternalICDXDT'],...
        'ReinitDXDTwhenXreachesSaturation',...
        get_param(block, 'ReinitDXDTwhenXreachesSaturation'));
end

% Set the reset conversion for internal events
% This is needed because the block now has a external reset
% Therefore, we need to merge two resets into one
if strcmp(sIntVariant, 'xLimitedWithReset')
    
    combineResetAndICs = [block '/CombineResetsAndICs'];

    internalResetModifier = [combineResetAndICs '/InternalResetModifier'];
    externalResetModifier = [combineResetAndICs '/ExternalResetModifier'];
    logicalCombine = [combineResetAndICs '/LogicalCombine'];
    
    switch get_param(block, 'ExternalReset')
        case 'rising'
            set_param(internalResetModifier, 'BlockChoice','risingI');
            set_param(externalResetModifier, 'BlockChoice','risingE');
            set_param(logicalCombine, 'Operator', 'OR');
        case 'falling'
            set_param(internalResetModifier, 'BlockChoice','fallingI');
            set_param(externalResetModifier, 'BlockChoice','fallingE');
            set_param(logicalCombine, 'Operator', 'NOR');
        case 'either'
            % Reverting the settings to rising which was set to either
            % previously. We convert either reset to rising internally
            set_param([block '/x'],'ExternalReset', 'rising');
            set_param([block '/dxdt'],'ExternalReset','rising');
            set_param(internalResetModifier, 'BlockChoice','risingI');
            set_param(externalResetModifier, 'BlockChoice','eitherE');
            set_param(logicalCombine, 'Operator', 'OR');
    end
end

% Set the parameter visibility on the mask prompt
setMaskParameterVisibilities(block)

end




%--------------------------------------------------------------------------
function configureInitialConditionSource(ICblockName, ICSource, ICValue)
% Helper function for configuring initial conditions source

isInternal = strcmp(get_param(ICblockName, 'BlockType'), 'Constant');

switch ICSource
    case 'internal'
        if ~isInternal
            replaceBlockInDiscretizedSystem(ICblockName,'built-in/Constant');
        end
        set_param(ICblockName, 'Value',ICValue);
    case 'external'
        if isInternal
            replaceBlockInDiscretizedSystem(ICblockName, 'built-in/Inport');
        end
end
end




%--------------------------------------------------------------------------
function configureOutports(block)
% Configure which output port is shown
ShowOutput = get_param(block,'ShowOutput');

% Get the current configuration
xEnabled = strcmp(get_param([block '/xOut'],'BlockType'), 'Outport');
dxEnabled = strcmp( get_param([block '/dxOut'],'BlockType'), 'Outport');

% Get the desired configuration
xDesired = true;
dxDesired = true;

switch ShowOutput
    case 'x'
        dxDesired = false;
    case 'dxdt'
        xDesired = false;
    case 'both'
        % Nothing to do, already set to true
end
if xEnabled ~= xDesired
    if xDesired
        replaceBlockInDiscretizedSystem([block,'/xOut'],...
                                        'built-in/Outport');
    else
        replaceBlockInDiscretizedSystem([block,'/xOut'],...
                                        'built-in/Terminator');
    end
end
if dxEnabled ~= dxDesired
    if dxDesired
        replaceBlockInDiscretizedSystem([block '/dxOut'],...
                                        'built-in/Outport');
    else
        replaceBlockInDiscretizedSystem([block '/dxOut'],...
                                        'built-in/Terminator');
    end
end
end




%--------------------------------------------------------------------------
function replaceBlockInDiscretizedSystem(oldBlock, newBlock)
% Replace a block in the discretized subsystem

% Get the position and orientation
position = get_param(oldBlock,'Position'); 
orientation = get_param(oldBlock,'Orientation');

% Delete the old block
delete_block(oldBlock); 

% Add the new block with the old name and the old position/orientation
add_block(newBlock,oldBlock,'Position',position, 'Orientation',orientation); 

end




%--------------------------------------------------------------------------
function setMaskParameterVisibilities(block)
% Helper function to set visibility for mask prompts depending upon the
% values of the parameters

% Get the variable names and current visibility
varName = get_param(block, 'MaskNames');
visibility = get_param(block, 'MaskVisibilities');

for iv = 1 : length(varName)
    % Retain the current visibility setting that is set in the mask editor
    % for variables in which we are not interested.
    isVisible = true;
    if (strcmp(visibility{iv}, 'off'))
        isVisible = false;
    end
    
    % Modify ICX
    if (strcmp(varName{iv},'ICX') )
        isVisible = strcmp(get_param (block, 'ICSourceX'),'internal');
    end
    
    % Modify ICDXDT
    if (strcmp(varName{iv},'ICDXDT') )
        isVisible = strcmp(get_param (block, 'ICSourceDXDT'),'internal');
    end
    
    % Modify Limits for dx/dt
    if (strcmp(varName{iv},'UpperLimitDXDT') ||...
            strcmp(varName{iv},'LowerLimitDXDT') )
        isVisible = strcmp(get_param (block, 'LimitDXDT'),'on');
    end
    
    % Set the visibility. The old value is re-set if we did not modify it 
    if (isVisible)
        visibility{iv} = 'on';
    else
        visibility{iv} = 'off';
    end
end

% Done: Set it on the mask
set_param(block,'MaskVisibilities',visibility);

end



