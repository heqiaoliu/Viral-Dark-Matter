function [BlockSubs,Jout] = utCreateDelayBlockSubs(this,Jin,UserBlockSubs)
% UTCREATEDELAYBLOCKSUBS  Find the delay blocks that can be replaced with
% exact delays.  If a user has specified a block replacement by themselves
% then do not do a substitution.
%

% Author(s): John W. Glass 03-Sep-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2009/03/31 00:22:24 $

% Find the transport, variable transport, and integer delays
BlockType = get_param(Jin.Mi.BlockHandles,'BlockType');
ind_td = find(strcmp(BlockType,'TransportDelay'));
ind_vtd = find(strcmp(BlockType,'VariableTransportDelay'));
ind_ud = find(strcmp(BlockType,'UnitDelay'));

% Remove any bus expanded unit delays
for ct = numel(ind_ud):-1:1
    b = get_param(Jin.Mi.BlockHandles((ind_ud(ct))),'Object');
    % Do not substitute exact delay for bus expanded unit delays
    if b.isSynthesized;
        ind_ud = [];
    end
end

% Find the integer delays
ind_sfun = find(strcmp(BlockType,'S-Function'));
ReferenceBlocks = get_param(Jin.Mi.BlockHandles(ind_sfun),'ReferenceBlock');
ind_id = ind_sfun(strcmp(ReferenceBlocks,'simulink/Discrete/Integer Delay'));
block_ind = [ind_td;ind_vtd;ind_ud;ind_id];

% If there are not any delay blocks return
if numel(block_ind) == 0
    BlockSubs = UserBlockSubs;
    Jout = Jin;
    return
end

% Remove any blocks that the user has specified substitutions
if ~isempty(UserBlockSubs)
    UserBlockSubNames = {UserBlockSubs.Name};
    for ct = numel(block_ind):-1:1
        if any(strcmp(getfullname(Jin.Mi.BlockHandles(block_ind(ct))),UserBlockSubNames))
            block_ind(ct) = [];
        end
    end
end

% Get the delay block information
DelayBlockHandles = Jin.Mi.BlockHandles(block_ind);
DelayBlockNames = getfullname(DelayBlockHandles);
if numel(DelayBlockHandles) == 1
    DelayBlockNames = {DelayBlockNames};
end 
DelayBlockSubs = struct('Name',DelayBlockNames,'Value',[]);

% Get the actual delay values - Transport Delay
for ct = 1:numel(ind_td)
    r = get_param(Jin.Mi.BlockHandles((ind_td(ct))),'RunTimeObject');
    BlockDelay = r.DialogPrm(1).Data;
    nInputs = prod(r.InputPort(1).Dimensions);
    nOutputs = prod(r.OutputPort(1).Dimensions);
    if numel(BlockDelay) == 1 && nInputs > 1
        BlockDelay = BlockDelay * ones(nInputs,1);
    end
    DelayBlockSubs(ct).Value = ss(eye(nOutputs,nInputs),...
        'OutputDelay',BlockDelay,'Ts',0);
end
offset = numel(ind_td);

% Get the actual delay values - Variable Transport/Time Delay
for ct = 1:numel(ind_vtd)
    r = get_param(Jin.Mi.BlockHandles((ind_vtd(ct))),'RunTimeObject');
    nInputs1 = prod(r.InputPort(1).Dimensions);
    nInputs2 = prod(r.InputPort(2).Dimensions);
    nOutputs = prod(r.OutputPort(1).Dimensions);
    inport = r.InputPort(2).Data;    
    lindata = [eye(nOutputs,nInputs1);zeros(nOutputs,nInputs2)];
    DelayBlockSubs(ct+offset).Value = ss(lindata,...
                    'OutputDelay',inport,'Ts',0);
end
offset = offset + numel(ind_vtd);

% Get the actual delay values - Unit Delay
for ct = 1:numel(ind_ud)
    r = get_param(Jin.Mi.BlockHandles((ind_ud(ct))),'RunTimeObject');
    nInputs = prod(r.InputPort(1).Dimensions);
    nOutputs = prod(r.OutputPort(1).Dimensions);
    DelayBlockSubs(ct+offset).Value = ss(eye(nOutputs,nInputs),...
        'OutputDelay',1,'Ts',r.SampleTimes(1));
end
offset = offset + numel(ind_ud);

% Get the actual delay values - Integer Delay
for ct = 1:numel(ind_id)
    r = get_param(Jin.Mi.BlockHandles((ind_id(ct))),'RunTimeObject');
    nInputs = prod(r.InputPort(1).Dimensions);
    nOutputs = prod(r.OutputPort(1).Dimensions);
    DelayBlockSubs(ct+offset).Value = ss(eye(nOutputs,nInputs),...
        'OutputDelay',r.DialogPrm(3).Data*ones(size(inport)),'Ts',r.SampleTimes(1));
end

BlockSubs = [DelayBlockSubs;UserBlockSubs];

% Add the needed IOs to the LFT
Jout = Jin;
nblk = numel(Jin.Mi.BlockHandles);
for ct = 1:numel(DelayBlockSubs)
    BlockName = DelayBlockSubs(ct).Name;
    ph = get_param(DelayBlockSubs(ct).Name,'PortHandles');
    % Add the output channels if they are not yet set.
    nout = size(DelayBlockSubs(ct).Value,1);
    if ~any(strcmp(BlockName,Jout.Mi.OutputName))        
        Jout.Mi.OutputName = [Jout.Mi.OutputName;...
                                repmat(BlockName,nout,1)];        
        Jout.Mi.OutputPorts = [Jout.Mi.OutputPorts;...
                                repmat(ph.Outport,nout,1)];
        % Use the block list to find the column indices to G
        ind_blk = find(get_param(BlockName,'Handle') == Jin.Mi.BlockHandles);
        Gadd = sparse(nout,nblk);
        for dt = 1:numel(ind_blk)
            Gadd(dt,ind_blk(dt)) = 1;
        end
        Jout.Mi.G = [Jout.Mi.G;Gadd];
    end
    
    % Add the input channels if they are not yet set.
    for dt = 1:numel(ph.Inport)
        pc = get_param(BlockName,'PortConnectivity');
        p = LocalGetPortHandle(pc(dt).SrcBlock,pc(dt).SrcPort+1);
        if ~any(Jout.Mi.OutputPorts == p)
            
        end
    end
end


function p = LocalGetPortHandle(block,portnumber)

phs = get_param(block,'PortHandles');
ph = phs.Outport(portnumber);

