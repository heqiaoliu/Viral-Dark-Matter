function J = postProcessJacobian(this,J)
% POSTPROCESSJACOBIAN  Perform standard post processing of the Jacobian
% structure.
%
 
% Author(s): John W. Glass 12-Jun-2007
%   Copyright 2007-2010 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2010/05/10 17:56:17 $

% Construct the input and output block list.  This matrix contains the block
%  handles for each input/output along with the indices into the block port elements. 
nrows = size(J.Mi.E,1);
InputInfo = zeros(nrows,2);
ctr = 1;
for ct = 1:(length(J.Mi.InputIdx)-1)
    if (J.Mi.InputIdx(ct) ~= J.Mi.InputIdx(ct+1))
        lgnth = J.Mi.InputIdx(ct+1)-J.Mi.InputIdx(ct);
        InputInfo(ctr:ctr+lgnth-1,1) = J.Mi.BlockHandles(ct)*ones(lgnth,1);
        InputInfo(ctr:ctr+lgnth-1,2) = 1:lgnth;
        ctr = ctr + lgnth;
    end
end
InputInfo(ctr:end,1) = J.Mi.BlockHandles(end);
InputInfo(ctr:end,2) = (1:(nrows-ctr+1))';

nrows = size(J.Mi.E,2);
OutputInfo = zeros(nrows,2);
ctr = 1;
for ct = 1:(length(J.Mi.OutputIdx)-1)
    if (J.Mi.OutputIdx(ct) ~= J.Mi.OutputIdx(ct+1))
        lgnth = J.Mi.OutputIdx(ct+1)-J.Mi.OutputIdx(ct);
        OutputInfo(ctr:ctr+lgnth-1) = J.Mi.BlockHandles(ct)*ones(lgnth,1);
        OutputInfo(ctr:ctr+lgnth-1,2) = 1:lgnth;
        ctr = ctr + lgnth;
    end
end
OutputInfo(ctr:end,1) = J.Mi.BlockHandles(end);
OutputInfo(ctr:end,2) = (1:(nrows-ctr+1))';

% Rename the state block path.  This will reduce confusion later in
% linearization code
J.stateBlockPath = J.blockName;
J = rmfield(J,'blockName');

% Store the input and output block lists
J.Mi.InputInfo = InputInfo;
J.Mi.OutputInfo = OutputInfo;

% Store the initial output delays
J.Mi.OutputDelay = zeros(size(OutputInfo,1),1);

% Get the model sample times
nxz = size(J.A,1);
J.Tsx = J.Ts(1:nxz);
J.Tsy = J.Ts(nxz+1:end);

% Extract index elements, tack on the number of states, inputs, and
% outputs to account for the last block in the list.  Convert from
% C-indexing to Matlab-indexing.
[ny,nu] = size(J.D);
J.Mi.InputIdx = [J.Mi.InputIdx+1;nu+1];
J.Mi.OutputIdx = [J.Mi.OutputIdx+1;ny+1];
J.Mi.StateIdx = [J.Mi.StateIdx+1;nxz+1];

% The initial set of blocks in the linearization path are all the blocks
J.Mi.BlocksInPath = ones(numel(J.Mi.BlockHandles),1);

% Get the actual block port handle in the case of where linearization 
% points are added to nonvirtual expanded blocks.
for ct = 1:numel(J.Mi.InputPorts)
    try
        b = get_param(get_param(J.Mi.InputPorts(ct),'Parent'),'Object');
        isSynthesized = b.isSynthesized;
    catch Ex
        isSynthesized = true;
    end
    if (isSynthesized) && (~strcmp(getBlockPath(slcontrol.Utilities,J.Mi.InputName{ct}),get_param(J.Mi.InputPorts(ct),'Parent')))
        % Get the path to the block relative to its model
        blkpath = getBlockPath(slcontrol.Utilities,J.Mi.InputName{ct});
        blkroot = bdroot(blkpath);
        % Get the specific instance of the model being referenced. 
        ExpandedBlockPath = getfullname(J.Mi.InputPorts(ct));
        ind = strfind(ExpandedBlockPath,'/');
        RefMdlRoot = ExpandedBlockPath(1:(ind(1)-1));
        blkpath = sprintf('%s%s',RefMdlRoot,blkpath(numel(blkroot)+1:end));
        ph = get_param(blkpath,'PortHandles');
        J.Mi.InputPorts(ct) = ph.Outport;
    end
end
for ct = 1:numel(J.Mi.OutputPorts)
    try
        b = get_param(get_param(J.Mi.OutputPorts(ct),'Parent'),'Object');
        isSynthesized = b.isSynthesized;
    catch Ex
        isSynthesized = true;
    end
    if (isSynthesized) && (~strcmp(getBlockPath(slcontrol.Utilities,J.Mi.OutputName{ct}),get_param(J.Mi.OutputPorts(ct),'Parent')))
        % Get the path to the block relative to its model
        blkpath = getBlockPath(slcontrol.Utilities,J.Mi.OutputName{ct});
        blkroot = bdroot(blkpath);
        % Get the specific instance of the model being referenced. 
        ExpandedBlockPath = getfullname(J.Mi.OutputPorts(ct));
        ind = strfind(ExpandedBlockPath,'/');
        RefMdlRoot = ExpandedBlockPath(1:(ind(1)-1));
        blkpath = sprintf('%s%s',RefMdlRoot,blkpath(numel(blkroot)+1:end));
        ph = get_param(blkpath,'PortHandles');
        J.Mi.OutputPorts(ct) = ph.Outport;
    end
end

% Sort the IOs to account for bus expansion
blockNames = getfullname(J.Mi.BlockHandles);
input_ind_perm = LocalOrderPorts(J.Mi.InputPorts,blockNames,J.Mi.BlockHandles);
output_ind_perm = LocalOrderPorts(J.Mi.OutputPorts,blockNames,J.Mi.BlockHandles);
J.Mi.InputPorts(input_ind_perm) = J.Mi.InputPorts;
J.Mi.F(:,input_ind_perm) = J.Mi.F;
J.Mi.G(output_ind_perm,:) = J.Mi.G;
J.Mi.OutputPorts(output_ind_perm) = J.Mi.OutputPorts;
J.Mi.H(output_ind_perm,input_ind_perm) = J.Mi.H;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ind_perm = LocalOrderPorts(Ports,blockNames,blockHandles)

% Sort the order of expanded buses for io points
Parents = get_param(get_param(Ports,'Parent'),'Handle');
if iscell(Parents)
    Parents = [Parents{:}];
end
[uParents,ind_unique] = unique(Parents);
uPorts = Ports(ind_unique);

% Find the blocks that are virtual or bus expanded non-virtual
virtualblocks = uParents(~ismember(uParents,blockHandles));

% Now find all the expanded blocks
ind_perm = 1:numel(Ports);
for ct = 1:numel(uPorts)
    if any(get_param(get_param(uPorts(ct),'Parent'),'Handle')==virtualblocks)
        ind = find(uPorts(ct)==Ports);
        blockname = get_param(uParents(ct),'Name');
        blockparent = get_param(uParents(ct),'Parent');
        % First look for bus expanded linearization points with added
        % SignalConversion blocks.
        portnumber = get_param(uPorts(ct),'PortNumber');
        synthblockname = sprintf('Hidden_Linearization_Block_At_Output_of_%s_at_port_%d',blockname,portnumber);
        synthname = sprintf('%s/%s/%s_',blockparent,synthblockname,synthblockname);
        synthblocks = blockHandles(strncmp(synthname,blockNames,numel(synthname)));
        % Next look for signal conversion blocks added on regular virtual blocks
        if isempty(synthblocks)
            synthblockname = sprintf('Hidden_Linearization_Block_At_Output_of_%s_at_port_%d',blockname,portnumber);
            synthname = sprintf('%s/%s',blockparent,synthblockname);
            synthblocks = blockHandles(strncmp(synthname,blockNames,numel(synthname)));
        end
        % If no SignalConversion blocks are found then search for the bus
        % expanded non-virtual blocks.
        if isempty(synthblocks)
            synthname = sprintf('%s/%s/%s_',blockparent,blockname,blockname);
            synthblocks = blockHandles(strncmp(synthname,blockNames,numel(synthname)));
        end
        % If there is more then one synthblock then we know that there is
        % expansion.
        if numel(synthblocks) > 1
            repsynthblocks_int = [];
            % Get the integer representation of the expanded block index
            synthblockname = getfullname(synthblocks);
            synthblocks_int_char = regexprep(synthblockname,synthname,'');
            synthblocks_int = str2double(synthblocks_int_char);
            % Eliminate bus creator and bus selector in the expansion
            indNaN = find(isnan(synthblocks_int));
            synthblocks_int(indNaN)= [];
            synthblocks(indNaN) = [];
            % Handle case where bus signal is a non-scalar
            for ct2 = 1:numel(synthblocks)
                ph = get_param(synthblocks(ct2),'PortHandles');
                cpw = prod(get_param(ph.Outport,'CompiledPortWidth'));
                repsynthblocks_int = [repsynthblocks_int;synthblocks_int(ct2)*ones(cpw,1)];
            end
            % Get the names of the synthesized block
            [~,indsort] = sort(repsynthblocks_int);
            % Expand for the case of multi-instance normal mode where a
            % linearization IO could be repeated
            nch = numel(indsort);
            nrefs = numel(ind)/nch;
            indsort_ini = indsort;
            for ct2 = 1:(nrefs-1)
                indsort = [indsort;indsort_ini+nch];
            end
            
            % Permute the order
            ind_perm(ind(indsort)) = ind;
        end
    end
end
