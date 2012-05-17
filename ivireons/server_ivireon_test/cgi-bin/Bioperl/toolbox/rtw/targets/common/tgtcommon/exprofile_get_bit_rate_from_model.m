function config_for_class = exprofile_get_bit_rate_from_model(modelName, ...
                                                      profiling_blocks)
%EXPROFILE_GET_BIT_RATE_FROM_MODEL get execution profiling bit-rate info from a model
%   CONFIG_FOR_CLASS = EXPROFILE_GET_BIT_RATE_FROM_MODEL(MODELNAME,
%   PROFILING_BLOCK_LIST) identifies the resource configuration class in
%   MODELNAME where the bit-rate used for execution profiling is
%   set. PROFILING_BLOCK_LIST must contain a structure array with fields
%   block_mask_id and class corresponding to each execution profiling block that
%   is being searched for.

% Copyright 2006 The MathWorks, Inc.


% Is the model open
model_open = find_system('type', 'block_diagram', 'BlockDiagramType', 'model', 'Name', modelName);
if (length(model_open) < 1)
  TargetCommon.ProductInfo.error('profiling', 'ProfilingModelBitrate', modelName);
end

block_h_list = {};
for i=1:length(profiling_blocks)
  % Search for the block
  block_h = find_system(modelName, 'FollowLinks', 'on', 'LookUnderMasks', 'on', ...
                        'MaskType', profiling_blocks(i).block_mask_id);
  found_block = length(block_h)>0;
  block_h_list = horzcat(block_h_list, block_h);
  % did we find a block
  if found_block
    % Store the class associated with the block
    config_class = profiling_blocks(i).class;
  end
end

if (length(block_h_list) < 1)
  % Execution profiling block not found
  msg = sprintf('Failed to find any execution profiling block,\n\n');
  for i=1:length(profiling_blocks)
      msg = sprintf([msg profiling_blocks(i).block_mask_id '\n'])
  end
  TargetCommon.ProductInfo.error('profiling', 'ProfilingModelMissingBlock', msg, modelName);
end
if (length(block_h_list) > 1)
  TargetCommon.ProductInfo.error('profiling', 'ProfilingModelTooManyBlocks', modelName);
end

% Get the block resources to query
targetClass = RTWConfigurationCB('get_target', block_h_list);
config_for_class = targetClass.findConfigForClass(config_class);
