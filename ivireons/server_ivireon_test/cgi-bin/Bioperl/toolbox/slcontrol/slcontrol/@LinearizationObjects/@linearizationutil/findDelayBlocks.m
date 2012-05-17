function DelayBlocks = findDelayBlocks(this,ModelParameterMgr,opts,BlockSubs)
% FINDDELAYBLOCKS  Find the delay blocks in a model for replacement
%

% Author(s): John W. Glass 10-Sep-2008
%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/04/11 20:40:51 $

if strcmp(opts.UseExactDelayModel,'on')
    % Get the models 
    mdls = ModelParameterMgr.getUniqueNormalModeModels;
    
    % Find the transport, variable transport, and integer delays
    ind_td = find_system(mdls,'FollowLinks','on','LookUnderMasks','all','BlockType','TransportDelay');
    ind_vtd = find_system(mdls,'FollowLinks','on','LookUnderMasks','all','BlockType','VariableTransportDelay');
    ind_ud = find_system(mdls,'FollowLinks','on','LookUnderMasks','all','BlockType','UnitDelay');
    
    % Remove any bus expanded unit delays
    for ct = numel(ind_ud):-1:1
        b = get_param(ind_ud{ct},'Object');
        % Do not substitute exact delay for bus expanded unit delays
        if b.isSynthesized;
            ind_ud(ct) = [];
        end
    end
    
    % Find the integer delays
    ind_id = find_system(mdls,'FollowLinks','on','LookUnderMasks','all',...
                               'BlockType','S-Function',...
                                'ReferenceBlock',...
                                'simulink/Discrete/Integer Delay');
    
    % Remove any delay blocks being replaced specifically by the user.
    DelayBlocks = [ind_td;ind_vtd;ind_ud;ind_id];
    if ~isempty(BlockSubs)
        BlockSubNames = {BlockSubs.Name};
        BlockSubH = get_param(BlockSubNames,'Handle');
        BlockSubH = [BlockSubH{:}];
        for ct = 1:numel(DelayBlocks)
            if any(get_param(DelayBlocks{ct},'Handle') == BlockSubH)
                DelayBlocks(ct) = [];
            end
        end
    end
else
    DelayBlocks = [];
end
