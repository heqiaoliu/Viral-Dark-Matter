function vector_init_mask(tag, block)
%VECTOR_INIT_MASK Check for duplicate id tags in Vector CAN Configuration
% blocks
%
%   VECTOR_INIT_MASK(tag, block)

%   Copyright 2001-2008 The MathWorks, Inc.
%   $Revision: 1.11.4.6 $
%   $Date: 2008/06/13 15:27:44 $

% make sure the config tag for this block is unique!
% search for config blocks.
% disable warnings whilst doing find_system because there may be uninitialised parameters
%
sysroot=strtok(block,'/');
sws = warning('off'); %#ok<WNOFF>
try
    configblock = find_system(sysroot,'LookUnderMasks','on',...
        'FollowLinks','on',...
        'MaskType',...
        'Vector CAN Configuration');
catch e
    warning(sws);
    rethrow(e);
end
warning(sws);

for i=1:length(configblock)
    % skip if it is the current block!
    if strcmp(configblock{i}, block)
        continue;
    end
    if strcmp(get_param(configblock{i},'tag_param'), tag)
        error('Targets:VectorCAN:duplicateTags', ...
            ['Another configuration block exists with tag %s.\nChange the ' ...
            'tag in one of the configuration blocks and associate the ' ...
            'required TX and RX blocks with that tag.'], tag);
    end
end