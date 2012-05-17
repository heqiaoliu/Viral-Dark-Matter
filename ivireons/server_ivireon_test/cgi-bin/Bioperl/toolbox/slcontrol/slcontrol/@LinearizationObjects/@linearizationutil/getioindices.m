function iostruct = getioindices(this,ModelParameterMgr,io,inports,outports,innames,outnames,flag,truncatename,useBus,varargin)
% Obtains the input output index information used in linearization.

%  Author(s): John Glass
%  Revised: Erman Korkut
%   Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2010/05/10 17:56:15 $

% Initialize name cell arrays and indices
i_name = {};o_name = {};
full_i_name = {};full_o_name = {};
full_i_port = [];full_i_ch = [];
full_o_port = [];full_o_ch = [];
i_ind = [];o_ind = [];

% Root level linearization
if strcmp(flag,'rootports')
    % Inports
    [i_name,full_i_name,full_i_port,full_i_ch,i_ind] = LocalCreateRootLevelLinLabels(inports,...
        truncatename,useBus,ModelParameterMgr);
    % Outports
    [o_name,full_o_name,full_o_port,full_o_ch,o_ind] = LocalCreateRootLevelLinLabels(outports,...
        truncatename,useBus,ModelParameterMgr);
else
    % Get the active IOs
    activeio = io(strcmp(get(io,'Active'),'on'));
    if strcmp(flag,'block')
        % If flag is 'block', the first argument is blockhandle
        blockhandle = varargin{1};
        % Block linearization
        for ct = 1:length(activeio)  
            if strcmp(activeio(ct).Type,'in')
                % Construct information for input labels
                [i_name,full_i_name,full_i_port,full_i_ch,i_ind] = LocalCreateBlockLinLabels(blockhandle,activeio(ct),inports,truncatename,useBus,ModelParameterMgr,...
                    i_name,full_i_name,full_i_port,full_i_ch,i_ind);
            else
                % Construct information for output labels
                [o_name,full_o_name,full_o_port,full_o_ch,o_ind] = LocalCreateBlockLinLabels(blockhandle,activeio(ct),outports,truncatename,useBus,ModelParameterMgr,...
                    o_name,full_o_name,full_o_port,full_o_ch,o_ind);
            end           
        end
    else
        % IO linearization
        for ct = 1:length(activeio)        
            if strcmp(activeio(ct).Type,'in')
                % Construct labels for input I/O
                [i_name,full_i_name,full_i_port,full_i_ch,i_ind] = LocalCreateIOLinLabels(activeio(ct),inports,innames,truncatename,useBus,ModelParameterMgr,...
                    i_name,full_i_name,full_i_port,full_i_ch,i_ind);
            elseif strcmp(activeio(ct).Type,'out')
                [o_name,full_o_name,full_o_port,full_o_ch,o_ind] = LocalCreateIOLinLabels(activeio(ct),outports,outnames,truncatename,useBus,ModelParameterMgr,...
                    o_name,full_o_name,full_o_port,full_o_ch,o_ind);
            elseif (strcmp(activeio(ct).Type,'outin') || strcmp(activeio(ct).Type,'inout'))
                % Construct labels for input-output I/O by treating it both as an input I/O and
                % an output I\O
                [i_name,full_i_name,full_i_port,full_i_ch,i_ind] = LocalCreateIOLinLabels(activeio(ct),inports,innames,truncatename,useBus,ModelParameterMgr,...
                    i_name,full_i_name,full_i_port,full_i_ch,i_ind);
                [o_name,full_o_name,full_o_port,full_o_ch,o_ind] = LocalCreateIOLinLabels(activeio(ct),outports,outnames,truncatename,useBus,ModelParameterMgr,...
                    o_name,full_o_name,full_o_port,full_o_ch,o_ind);
            end             
        end
    end
end

% Create the IO structure.
iostruct = struct('InputInd',{i_ind},'OutputInd',{o_ind},...
    'InputName',{i_name},'OutputName',{o_name},...
    'FullInputName',{full_i_name},'FullOutputName',{full_o_name},...
    'FullInputPort',{full_i_port},'FullOutputPort',{full_o_port},...
    'FullInputChannel',{full_i_ch},'FullOutputChannel',{full_o_ch},...
    'FullStateName',[]);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalCreateRootLevelLinLabels
%  Construct I/O labels for root-level linearization using inport/outports
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [name,full_name,full_port,full_ch,indices] = LocalCreateRootLevelLinLabels(ports,truncatename,useBus,ModelParameterMgr)
% Initialize output cell arrays
name = {};full_name = {};
full_port = [];full_ch = [];
% Obtain the unique ports in the same order as they appear in the original ports array
[~,m,~] = unique(ports,'first');
blockports = ports(sort(m));
% Label each port using the block or bus information
for ct = 1:length(blockports)
    port = blockports(ct);
    blkname = get_param(port,'Parent');
    % Make sure that port is not array of bus
    LocalCheckArrayOfBus(bdroot(blkname),port);
    ind = find(port==ports);
    if useBus && LocalIsBus(port)
        name = LocalLabelWithBusInfo(get_param(port,'Parent'),'',port,truncatename,name,ModelParameterMgr);
    else
        % If not a bus, label using block name of the port without the port number        
        if truncatename
            portname = getUniqueBlockName(slcontrol.Utilities,blkname,ModelParameterMgr);
        else
            portname = blkname;
        end
        iscomplex = get_param(port,'CompiledPortComplexSignal');
        dimensions = LocalProcessDimensions(get_param(port,'CompiledPortDimensions'),ind,iscomplex);
        name = LocalAppendIndexInfo(portname,dimensions,iscomplex,name);
    end
    % Append the info to full block data
    full_name(end+1:end+length(ind)) = strcat(get_param(port,'Parent'),cell(length(ind),1));
    full_port = [full_port;ones(length(ind),1)];
    full_ch = [full_ch;(1:length(ind))'];
end
% Construct full block index data
indices = 1:length(name);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalCreateBlockLinLabels
%  Construct I/O labels for block linearization using block name and port info
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [name,full_name,full_port,full_ch,indices] = LocalCreateBlockLinLabels(blockhandle,io,ports,truncatename,useBus,ModelParameterMgr,name,full_name,full_port,full_ch,indices)
% Get naming port and block
portnumber = io.Description;
blkname = getfullname(double(blockhandle.Handle));
% Get actual port and block
port_handles = get_param(io.Block,'PortHandles');
port = port_handles.Outport(io.PortNumber);
% Make sure that the port is not an array of bus
LocalCheckArrayOfBus(bdroot(blkname),port);
if truncatename
    blkname = get_param(blkname,'Name');
end
blkname = sprintf('%s/%s',blkname,portnumber); 
% Find the corresponding ports
ind = find(port==ports);
dims = get_param(port,'CompiledPortDimensions');
if useBus && LocalIsBus(port)
    name = LocalLabelWithBusInfo(blkname,'',port,false,name,ModelParameterMgr);
else
    iscomplex = get_param(port,'CompiledPortComplexSignal');
    dims = LocalProcessDimensions(dims,ind,iscomplex);
    name = LocalAppendIndexInfo(blkname,dims,iscomplex,name);
end
% Append the info to full block data
full_name(end+1:end+length(ind)) = strcat(io.Block,cell(length(ind),1));
full_port = [full_port;repmat(io.PortNumber,length(ind),1)];
full_ch = [full_ch(:);ind(:)];
indices(end+1:end+length(ind)) = ind;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalCreateIOLinLabels
%  Construct I/O labels for linearization with I/O points specified
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [name,full_name,full_port,full_ch,indices] = LocalCreateIOLinLabels(io,ports,ionames,truncatename,useBus,ModelParameterMgr,name,full_name,full_port,full_ch,indices)
port_handles = get_param(io.Block,'PortHandles');
port = port_handles.Outport(io.PortNumber);

blkname = io.Block; 
ind = find(port==ports);
model = bdroot(blkname);
% Make sure that port is not an array of bus
LocalCheckArrayOfBus(model,port);
nInstances = ModelParameterMgr.findNumberNormalModeInstances(model);

if ~isequal(model,ModelParameterMgr.Model) && nInstances > 1
    % Find the parent model reference block name
    refblkname = ionames{ind(1)};
    refblkname = refblkname(1:end-numel(blkname)-1);
else
    refblkname = '';
end

if useBus && LocalIsBus(port)
    name = LocalLabelWithBusInfo(blkname,refblkname,port,truncatename,name,ModelParameterMgr);
elseif ~isempty(get_param(port,'Name'))
    name = LocalLabelWithSignalInfo(blkname,refblkname,port,truncatename,name,ind,ModelParameterMgr);
else
    name = LocalLabelWithBlockInfo(blkname,refblkname,port,truncatename,name,ind,ModelParameterMgr);
end

% Tack on un-bound normal mode model references if they exist.
if nInstances > 1
    for ct = 0:nInstances-2 
        unboundblkname = sprintf('%s%d%s',blkname(1:numel(model)),ct,blkname(numel(model)+1:end));
        port_handles = get_param(unboundblkname,'PortHandles');
        port = port_handles.Outport(io.PortNumber);
        indref = find(port == ports);
        ind = [ind; indref];
        
        % Find the parent model reference block name
        refblkname = ionames{indref};
        refblkname = refblkname(1:end-numel(unboundblkname));
        
if useBus && LocalIsBus(port)
            name = LocalLabelWithBusInfo(blkname,refblkname,port,truncatename,name,ModelParameterMgr);
elseif ~isempty(get_param(port,'Name'))
            name = LocalLabelWithSignalInfo(blkname,refblkname,port,truncatename,name,indref,ModelParameterMgr);
else
            name = LocalLabelWithBlockInfo(blkname,refblkname,port,truncatename,name,indref,ModelParameterMgr);
end
    end
end

% Append the info to full block data
full_name(end+1:end+length(ind)) = strcat(io.Block,cell(length(ind),1));
full_port = [full_port;repmat(io.PortNumber,length(ind),1)];
full_ch = [full_ch(:);ind(:)];
indices(end+1:end+length(ind)) = ind;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalLabelWithBlockInfo
%  Construct I/O labels using the block and port information
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = LocalLabelWithBlockInfo(blkname,refblkname,port,truncatename,str,ind,ModelParameterMgr)
if truncatename
    name = getUniqueBlockName(slcontrol.Utilities,blkname,ModelParameterMgr);
else
    name = blkname;
end

% Tack on model reference block name if it is available
if ~isempty(refblkname)
    name = sprintf('%s|%s',refblkname,name);
end

% Add port number if the block has multiple outports
ph = get_param(blkname,'PortHandles');
if length(ph.Outport) > 1
    name = sprintf('%s/%d',name,get_param(port,'PortNumber'));
end
iscomplex = get_param(port,'CompiledPortComplexSignal');
dimensions = LocalProcessDimensions(get_param(port,'CompiledPortDimensions'),ind,...
    iscomplex);
str = LocalAppendIndexInfo(name,dimensions,iscomplex,str);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalLabelWithSignalInfo
%  Construct I/O labels using the signal name information
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = LocalLabelWithSignalInfo(blkname,refblkname,port,truncatename,str,ind,ModelParameterMgr)
if truncatename
    name = getUniqueSignalName(slcontrol.Utilities,port,ModelParameterMgr);
else
    name = sprintf('%s/%s',blkname,get_param(port,'Name'));
end

% Tack on model reference block name if it is available
if ~isempty(refblkname)
    name = sprintf('%s|%s',refblkname,name);
end

iscomplex = get_param(port,'CompiledPortComplexSignal');
dimensions = LocalProcessDimensions(get_param(port,'CompiledPortDimensions'),ind,...
    iscomplex);
str = LocalAppendIndexInfo(name,dimensions,iscomplex,str);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalLabelWithBusInfo
%  Construct I/O labels using bus signal name information
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = LocalLabelWithBusInfo(blkname,refblkname,port,truncatename,str,ModelParameterMgr)
util = slcontrol.Utilities;
businfo = get_param(port,'CompiledBusStruct');
busstr = {};        
% Get the bus information
if isempty(businfo)
    srcblock = get_param(port,'Parent');
    if isRootInport(util,srcblock)
        % Root level inport with BusObject
        objname = get_param(srcblock,'BusObject');
        busobj = slResolve(objname,srcblock);
        location = getBoundObjectName(busobj);
        busstr = LocalTraverseBusObject(busobj,srcblock,busstr,location);
    else
        % A subsystem output whose source has cached bus structure
        outport = find_system(srcblock,'SearchDepth',1,'BlockType','Outport','Port',num2str(get_param(port,'PortNumber')));
        ph = get_param(outport{1},'PortHandles');
        businfo = get_param(ph.Inport,'CompiledBusStruct');
        busstr = LocalTraverseCachedBus(businfo,busstr,'');
    end
else
    % Port itself has compiled bus structure
    busstr = LocalTraverseCachedBus(businfo,busstr,'');
end
% Prepend block name depending on full name option
if ~truncatename
    % Prepend the full name
    busstr = strcat(sprintf('%s/',blkname),busstr);  
else
    busstr = strcat(sprintf('%s/',getUniqueBlockName(util,blkname,ModelParameterMgr)),busstr);
end

% Tack on model reference block name if it is available
for ct = 1:numel(busstr)
    if ~isempty(refblkname)
        busstr{ct} = sprintf('%s|%s',refblkname,busstr{ct});
    end
end

% Add the labels
str = [str busstr];
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalAppendIndexInfo
% Construct I/O name by appending the index information to the source name
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = LocalAppendIndexInfo(name,dimensions,iscomplex,str)
numdims = length(dimensions);
numsigs = prod(dimensions);
if numsigs == 1 && ~iscomplex
    % If scalar double, add only signal name itself
    str{end+1} = sprintf('%s',name);
elseif isequal(dimensions,[1 1]) && iscomplex
    % Scalar but complex
    str{end+1} = sprintf('%s (real)',name);
    str{end+1} = sprintf('%s (imag)',name);
elseif dimensions(1) == 1
    % Bus to be labeled as a flattened vector
    for ct = 1:numsigs
        str{end+1} = sprintf('%s (%d)',name,ct);
    end
else
    % Matrix or n-D
    % Construct the index string
    for ct = 1:numsigs
        ind = cell(1,numdims);
        [ind{1:numdims}] = ind2sub(dimensions,ct);
        strind = sprintf('(%d',ind{1});
        for ctd = 2:length(ind)
            strind = sprintf('%s,%d',strind,ind{ctd});
        end
        strind = sprintf('%s)',strind);
        if ~iscomplex
            str{end+1} = sprintf('%s %s',name,strind);
        else
            % If complex, each element will have real and imaginary
            % portions.
            str{end+1} = sprintf('%s %s (real)',name,strind);
            str{end+1} = sprintf('%s %s (imag)',name,strind);
        end        
    end
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalProcessDimensions
% Bring the dimensions into appropriate format for index construction handling edge cases
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dims = LocalProcessDimensions(dimensions,ind,iscomplex)
if dimensions(1) == -2 
    % If signal is composite, use length of indices
    dims = [1 length(ind)];
elseif isequal(dimensions,[1 1])
    % Special attention for scalar, it might be a nonvirtual bus/complex
    if iscomplex
        dims = [1 1];
    else
        dims = [1 length(ind)];
    end
else
    dims = dimensions(2:end);
end
end
   
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalIsBus
% Check if a port is bus or not
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bool = LocalIsBus(port)
bool = false;
% Check if the port has compiled bus structure
if ~isempty(get_param(port,'CompiledBusStruct'))
    bool = true;
    return
else
    block = get_param(port,'Parent');
    % Check if the port belongs to a root level inport with BusObject
    if isRootInport(slcontrol.Utilities,block) && strcmp(get_param(block,'UseBusObject'),'on')
        bool = true;
        return;
    elseif strcmp(get_param(block,'BlockType'),'SubSystem')
        % Check if the port is at the output of a subsystem whose associated port has compiled bus
        % structure
        outport = find_system(block,'SearchDepth',1,'BlockType','Outport','Port',num2str(get_param(port,'PortNumber')));
        ph = get_param(outport{1},'PortHandles');
        if ~isempty(get_param(ph.Inport,'CompiledBusStruct'))
            bool = true;
        end
    end
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalTraverseCachedBus
% Traverse the N-ary businfo tree that is cached using CacheCompiledBusStruct options in a postorder
% way
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = LocalTraverseCachedBus(businfo,str,location)
if ~isempty(businfo.busObjectName)
    % It is a bus object, use recursive bus object traversal
    busobj = slResolve(businfo.busObjectName,businfo.src);
    % Branch to prevent initial "/" in the location
    if isempty(location)
        nextlocation = sprintf('%s',getBoundObjectName(busobj));
    else
        nextlocation = sprintf('%s/%s',location,getBoundObjectName(busobj));
    end
    str = LocalTraverseBusObject(busobj,businfo.src,str,regexprep(nextlocation,'//','/'));
    return;
elseif isempty(businfo.signals)
    % Get the dimension for this signal
    ph = get_param(businfo.src,'PortHandles');
    p = ph.Outport(businfo.srcPort+1);
    dims = get_param(p,'CompiledPortDimensions');
    % Exclude number of dimensions
    dims = dims(2:end);
    % Create string handling /'s in signal names
    str = LocalAppendIndexInfo(sprintf('%s',regexprep(location,'//','/')),dims,...
        get_param(p,'CompiledPortComplexSignal'),str);
    return;
else % It is a nested bus, recurse down
    for ct = 1:length(businfo.signals)
        % Branch to prevent initial "/" in the location
        if isempty(location)
            nextlocation = sprintf('%s',regexprep(businfo.signals(ct).name,'/','//'));
        else
            nextlocation = sprintf('%s/%s',location,regexprep(businfo.signals(ct).name,'/','//'));
        end
        str = LocalTraverseCachedBus(businfo.signals(ct),str,nextlocation);
    end
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalTraverseBusObject
% Traverse the N-ary bus object tree in a postorder way
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = LocalTraverseBusObject(busobj,block,str,location)
% First check if we are at a bus element level
if isa(busobj,'Simulink.BusElement')
    % Check for the datatype in the base workspace(to distinguish if it is another bus or not)
    dtype = busobj.DataType;
    out = evalin('base',['whos(''' dtype ''')']);
    if isempty(out) || ~strcmp(out.class,'Simulink.Bus')
        str = LocalAppendIndexInfo(sprintf('%s/%s',location,busobj.Name),...
            busobj.Dimensions,strcmp(busobj.Complexity,'complex'),str);
        return;
    else % It is another Simulink.Bus, recurse down
        nextlocation = sprintf('%s/%s',location,busobj.Name);
        str = LocalTraverseBusObject(slResolve(busobj.DataType,block),block,str,nextlocation);
    end
else
    for ct = 1:length(busobj.Elements)
        str = LocalTraverseBusObject(busobj.Elements(ct),block,str,location);
    end
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCheckArrayOfBus
% Check if a port carries an array of bus signal, error if this is the
% case. The port can be an array of bus if all the following is true
% 1. StrictBusMsg is not None or warning.
% 2. CompileBusType is a non-virtual bus.
% 3. Number of elements is not 1.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCheckArrayOfBus(mdl,port)
if ~any(strcmpi(get_param(mdl,'StrictBusMsg'),{'None','warning'})) && ...
   strcmp(get_param(port,'CompiledBusType'),'NON_VIRTUAL_BUS') && ...
   (prod(get_param(port,'CompiledPortDimensions')) ~= 1)
    % Error if array of bus
    ctrlMsgUtils.error('Slcontrol:linearize:LinearizationIOArrayOfBus');
end
end

