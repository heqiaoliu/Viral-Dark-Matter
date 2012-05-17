function [BlockSubs,DelayBlockRemovalData] = findDelayBlockLinearizations(this,J,BlockSubs)
% FINDDELAYBLOCKS  Find the delay blocks in a model for replacement
%

% Author(s): John W. Glass 10-Sep-2008
%   Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/07/09 20:55:20 $

% Find the transport, variable transport, and integer delays
BlockType = get_param(J.Mi.BlockHandles,'BlockType');
ind_td = find(strcmp(BlockType,'TransportDelay'));
ind_vtd = find(strcmp(BlockType,'VariableTransportDelay'));
ind_ud = find(strcmp(BlockType,'UnitDelay'));

% Remove any bus expanded unit delays
for ct = numel(ind_ud):-1:1
    b = get_param(J.Mi.BlockHandles((ind_ud(ct))),'Object');
    % Do not substitute exact delay for bus expanded unit delays
    if b.isSynthesized;
        ind_ud(ct) = [];
    end
end

% Find the integer delays
ind_sfun = find(strcmp(BlockType,'S-Function'));
ReferenceBlocks = get_param(J.Mi.BlockHandles(ind_sfun),'ReferenceBlock');
ind_id = ind_sfun(strcmp(ReferenceBlocks,'simulink/Discrete/Integer Delay'));

% Remove any delay blocks being replaced specifically by the user.
DelayBlockHandles = J.Mi.BlockHandles([ind_td;ind_vtd;ind_ud;ind_id]);
if ~isempty(BlockSubs)
    BlockSubH = get_param({BlockSubs.Name},'Handle');BlockSubH = [BlockSubH{:}];
    for ct = 1:numel(DelayBlockHandles)
        if any(DelayBlockHandles(ct) == BlockSubH)
            DelayBlockHandles(ct) = [];
        end
    end
end
DelayBlocks = struct('Name',getfullname(DelayBlockHandles),'Value',[],...
                        'FoldBlock',true);
DelayBlockRemovalData = struct('Block',cell(numel(DelayBlockHandles),1),...
    'nInputs',[],'InputHandles',[],...
    'nOutputs',[],'OutputHandles',[]);

for ct = 1:numel(DelayBlockHandles)
    r = get_param(DelayBlockHandles(ct),'RunTimeObject');
    switch get_param(DelayBlockHandles(ct),'BlockType')
        case 'TransportDelay'
            BlockDelay = r.DialogPrm(1).Data;
            nInputs = r.InputPort(1).Dimensions;
            if numel(BlockDelay) == 1 && nInputs > 1
                BlockDelay = BlockDelay * ones(nInputs,1);
            end
            sys = ss(eye(nInputs,nInputs),'Ts',0,'InputDelay',BlockDelay);
        case 'VariableTransportDelay'
            BlockDelay = r.InputPort(2).Data;
            nInputs = r.InputPort(1).Dimensions;
            sys = ss([eye(nInputs,nInputs),zeros(nInputs,nInputs)],'Ts',0,'InputDelay',[BlockDelay;zeros(nInputs,1)]);
        case 'UnitDelay'
            inport = r.InputPort(1).Data;
            Ts = r.SampleTimes(1);
            nInputs = r.InputPort(1).Dimensions;
            BlockDelay = ones(size(inport));
            sys = ss(eye(nInputs,nInputs),'Ts',Ts,'InputDelay',BlockDelay);
        otherwise % Integer Delay
            inport = r.InputPort(1).Data;
            nInputs = r.InputPort(1).Dimensions;
            Ts = r.SampleTimes(1);
            BlockDelay = r.DialogPrm(3).Data*ones(size(inport));
            sys = ss(eye(nInputs,nInputs),'Ts',Ts,'InputDelay',BlockDelay);
    end
    DelayBlockRemovalData(ct).Block = DelayBlockHandles(ct);
    DelayBlockRemovalData(ct).nInputs = nInputs;
    DelayBlockRemovalData(ct).InputHandles = DelayBlockHandles(ct)*ones(nInputs,1);
    DelayBlockRemovalData(ct).nOutputs = size(sys,1);
    DelayBlockRemovalData(ct).OutputHandles = DelayBlockHandles(ct)*ones(size(sys,1),1);
    DelayBlocks(ct).Name = getfullname(DelayBlockHandles(ct));
    DelayBlocks(ct).Value = sys;
end
BlockSubs = [BlockSubs(:);DelayBlocks];
