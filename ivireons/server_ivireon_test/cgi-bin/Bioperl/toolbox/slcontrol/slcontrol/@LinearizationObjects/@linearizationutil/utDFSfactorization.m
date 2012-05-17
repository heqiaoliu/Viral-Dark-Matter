function varargout = utDFSfactorization(this,ModelParameterMgr,node,ports,blocks,loopopenio)
% UTDFSFACTORIZATION 
%
 
% Author(s): John W. Glass 19-Jul-2005
%   Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.8.10 $ $Date: 2010/04/11 20:41:02 $

% Get the top model
topmdl = ModelParameterMgr.Model;

% Initialize the data for the first pass through
blocknames = getfullname(blocks);
pstop_port = node;
try
    blkpath = get_param(pstop_port,'Parent');
    pstop_block = get_param(blkpath,'Handle');
catch Ex %#ok<NASGU>
    pstop_block = blocks(strcmp(blkpath,getfullname(blocks)));
end

% Find all the normal model model reference blocks
[~,normalmdlblks] = ModelParameterMgr.getCompiledNormalModeModelBlockPaths;

% Initialize the time to be zero
ptime = 0;

% Initialize the node type to be a port
nodetype = true;

% Initialize data vectors for the ports
port_art = [];
nports = length(ports);
S.port_color = zeros(nports,1);
S.port_pred = -1*ones(nports,1);
S.port_disc = zeros(nports,1);
S.port_low = zeros(nports,1);
S.port_nch = zeros(nports,1);

% Initialize data vectors for the blocks
block_art = [];
nblocks = length(blocks);
S.block_color = zeros(nblocks,1);
S.block_pred = -1*ones(nblocks,1);
S.block_disc = zeros(nblocks,1);
S.block_low = zeros(nblocks,1);
S.block_nch = zeros(nblocks,1);

% Find the node
ind_u = getNodeInd(node,nodetype);
    
% Create the stack
Stack = struct('node',node,...
               'NodeInd',ind_u,...
               'nodetype',nodetype,...
               'StackChildren',[],...
               'AllZeroChildren',[],...
               'Children',[]);

% The stack starts at the first index
stackind = 1;

while stackind > 0
    % Get the node handle
    node = Stack(stackind).node;
    nodetype = Stack(stackind).nodetype;
    
    % Find the node
    ind_u = getNodeInd(node,nodetype);
    
    % Get the children if the node has not been touched
    if (getNodeColor(ind_u,nodetype) == 0) && isempty(Stack(stackind).AllZeroChildren)

        % Set the discovery time
        if (pstop_port == node)
            setNodeDiscovery(ind_u,inf,nodetype);
            % Set the Low variable to be the current time
            setNodeLow(ind_u,0,nodetype);
        else
            % Set the Low variable to be the current time
            setNodeLow(ind_u,ptime,nodetype);

            setNodeDiscovery(ind_u,ptime,nodetype);
            % Increment the time
            ptime = ptime + 1;
        end
        
        if stackind ~= 1
            % If this is the starting port then do not mark its discovery time
            % Set the color to be grey
            setNodeColor(ind_u,1,nodetype);
        end
    
        % Get the children
        dst_nodes = [];
        getChildren(node,nodetype);
        all_dst_nodes = dst_nodes;
        % Add the children to the stack
        for ct = numel(dst_nodes):-1:1
            % Find the destination node index
            ind_v = getNodeInd(dst_nodes(ct),~nodetype);
            if isempty(ind_v) %%|| (pstop_port == dst_nodes(ct)) || (pstop_block == dst_nodes(ct))
                dst_nodes(ct) = [];
                all_dst_nodes(ct) = [];
                continue
            end
            % If the child has not been touched add it to the list
            if (getNodeColor(ind_v,~nodetype) ~= 0)
                dst_nodes(ct) = [];
            end
        end
        % Store the children
        Stack(stackind).StackChildren = dst_nodes;
        Stack(stackind).Children = dst_nodes;
        Stack(stackind).AllZeroChildren = all_dst_nodes;
    elseif (getNodeColor(ind_u,nodetype) == 0) %%&& isempty(Stack(stackind).AllZeroChildren)
        % Set the Low variable to be the current time
        setNodeLow(ind_u,ptime,nodetype);
        dst_nodes = Stack(stackind).StackChildren;
    else
        dst_nodes = Stack(stackind).StackChildren;
    end
    
    % Walk up the stack if there a no stack children
    if (numel(dst_nodes) == 0) 
        % Find the low of all of the children
        % Get the children
        ch_nodes = Stack(stackind).Children;
        all_ch_nodes = Stack(stackind).AllZeroChildren;
     
        for ct = numel(all_ch_nodes):-1:1
            % Find the destination node index
            ind_v = getNodeInd(all_ch_nodes(ct),~nodetype);
            if ~isempty(find(ch_nodes==all_ch_nodes(ct), 1))
                if (pstop_port ~= node) %&& (pstop_block ~= node)
                    % Get the low of the child
                    child_low = getNodeLow(ind_v,~nodetype);
                    % Set the new low
                    % low(ind_u) = min(low(ind_u),low(ind_v))
                    new_low = min(getNodeLow(ind_u,nodetype), child_low);
                    % Condition 3
                    % (pred(ind_u) == 0) || (low(ind_v) >= discovery(ind_u))
                    if (getNodePred(ind_u,nodetype) == 0) || ...
                            (child_low >= getNodeDiscovery(ind_u,nodetype))
                        if nodetype
                            port_art(end+1) = node;
                        else
                            block_art(end+1) = node;
                        end
                    end
                    setNodeLow(ind_u,new_low,nodetype);
                end                
            elseif (ind_v ~= getNodePred(ind_u,nodetype))
                % (ind_v ~= pport_pred(ind_u))
                % low(ind_u) = min(low(ind_u),discovery(ind_v))
                new_low = min(getNodeLow(ind_u,nodetype),...
                    getNodeDiscovery(ind_v,~nodetype));
                setNodeLow(ind_u,new_low,nodetype);
            elseif isempty(ch_nodes)
                % Get the low of the child
                child_low = getNodeLow(ind_v,~nodetype);
                % Set the new low
                % low(ind_u) = min(low(ind_u),low(ind_v))
                new_low = min(getNodeLow(ind_u,nodetype), child_low);
                setNodeLow(ind_u,new_low,nodetype);
            end            
        end
        % Decriment the stack count since we are moving back up the stack
        stackind = stackind - 1;
    else
        % Remove a child from the current node
        dst_node = Stack(stackind).StackChildren(1);
        % Set the predacessor to be ind_u
        ind_v = getNodeInd(dst_node,~nodetype);
        Stack(stackind).StackChildren(1) = [];
        if getNodeColor(ind_v,~nodetype)
            % Remove this from the children list
            ind = find(Stack(stackind).Children == dst_node);
            Stack(stackind).Children(ind(1)) = [];
        end
        
        stackind = stackind + 1;            
        
        setNodePred(ind_v,ind_u,~nodetype);
        
        if numel(Stack) < stackind
            % Find the destination node index
            ind_v = getNodeInd(dst_node,~nodetype);
            NewStack = struct('node',dst_node,...
                'NodeInd',ind_v,...
                'nodetype',~nodetype,...
                'StackChildren',[],...
                'AllZeroChildren',[],...
                'Children',[]);
            Stack = [Stack;NewStack]; 
        else
            Stack(stackind).node = dst_node;
            Stack(stackind).NodeInd = ind_v;
            Stack(stackind).nodetype = ~nodetype;
            Stack(stackind).StackChildren = [];
            Stack(stackind).Children = [];
            Stack(stackind).AllZeroChildren = [];
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GETCHILDREN
    function getChildren(node,nodetype)
        if nodetype
            % If the node is a port then we need to search for destinations only
            % since the source block will always be an ancestor.  The parent block
            % will also be a node since we are treating this as a bi-directional graph.

            % Get all of the destination output ports
            if (pstop_port == node) || (any(node == loopopenio))
                dst_nodes = [];
            else
                % Tack on the port parent since it is the port node
                % parent.
                dst_parent = get_param(node,'Parent');
                try
                    dst_nodes = get_param(dst_parent,'Handle');
                catch DestinationException
                    if strcmp(DestinationException.identifier,'Simulink:Commands:InvSimulinkObjectName')
                        dst_nodes = blocks(strcmp(dst_parent,blocknames));
                    else
                        throwAsCaller(DestinationException);
                    end
                end
            end

            % Get the output port object
            src_port_obj = handle(node);

            % Get the actual destinations these will be the nodes to iterate
            % on.
            LocalGetActualDst(src_port_obj);
        else
            port_handles = get_param(node,'PortHandles');
            if (node ~= pstop_block)
                % If the node is block then we need to store each of the output ports
                % as destination nodes.
                dst_nodes = port_handles.Outport(:);
            else
                dst_nodes = [];
            end
            % Now determine if there are other source ports for this
            % block
            inports = port_handles.Inport;
            for ct1 = 1:length(inports)
                p = handle(inports(ct1));
                LocalGetActualSrc(p);
            end
        end
    end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalGetActualDst
    function LocalGetActualDst(port)
        act_dst = getActualDstMdlRef(linutil,port,topmdl,normalmdlblks);
        for ct_dst = 1:size(act_dst,1)
            dst_parent = get_param(act_dst(ct_dst,1),'Parent');
            try
                dst_block = get_param(dst_parent,'Handle');
                dst_nodes(end+1) = dst_block;
            catch DestinationException
                if strcmp(DestinationException.identifier,'Simulink:Commands:InvSimulinkObjectName')
                    dst_nodes = [dst_nodes,blocks(strcmp(dst_parent,blocknames))];
                else
                    throwAsCaller(DestinationException);
                end
            end
        end
    end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalGetActualSrc
    function LocalGetActualSrc(port)
        act_src = getActualSrcMdlRef(linutil,port,topmdl,normalmdlblks);
        dst_nodes = [dst_nodes;act_src(:,1)];
    end
        
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getNodeInd
    function ind = getNodeInd(node,nodetype)

        if nodetype
            ind = find(node == ports);
        else
            ind = find(node == blocks);
        end
    end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setNodeColor
    function setNodeColor(ind,color,nodetype)

        if nodetype
            S.port_color(ind) = color;
        else
            S.block_color(ind) = color;
        end
    end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getNodeColor
    function color = getNodeColor(ind,nodetype)

        if nodetype
            color = S.port_color(ind);
        else
            color = S.block_color(ind);
        end
    end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setNodeLow
    function setNodeLow(ind,low,nodetype)

        if nodetype
            S.port_low(ind) = low;
        else
            S.block_low(ind) = low;
        end
    end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getNodeLow
    function low = getNodeLow(ind,nodetype)

        if nodetype
            low = S.port_low(ind);
        else
            low = S.block_low(ind);
        end
    end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getNodePred
    function pred = getNodePred(ind,nodetype)

        if nodetype
            pred = S.port_pred(ind);
        else
            pred = S.block_pred(ind);
        end
    end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setNodePred
    function setNodePred(ind,pred,nodetype)

        if nodetype
            S.port_pred(ind) = pred;
        else
            S.block_pred(ind) = pred;
        end
    end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setNodeDiscovery
    function setNodeDiscovery(ind,discovery,nodetype)

        if nodetype
            S.port_disc(ind) = discovery;
        else
            S.block_disc(ind) = discovery;
        end
    end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getNodeDiscovery
    function discovery = getNodeDiscovery(ind,nodetype)

        if nodetype
            discovery = S.port_disc(ind);
        else
            discovery = S.block_disc(ind);
        end
    end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargout > 0
    varargout{1} = port_art;
    varargout{2} = S.port_low;
    varargout{3} = S.port_disc;
    varargout{4} = block_art;
    varargout{5} = S.block_low;
    varargout{6} = S.block_disc;
end
end
