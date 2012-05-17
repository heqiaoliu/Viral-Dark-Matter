function Jfull = utLFTPnt2Pnt(this,ModelParameterMgr,Jfull,inpoint,outpoint,BlockInputNames,BlockOutputNames)
% LFTPNT2PNT Compute the Jacobian data for a pair of input and output
% points.
%  Author(s): John Glass
%   Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2010/04/11 20:41:06 $

topmdl = ModelParameterMgr.Model;
[~,normalmdlblks] = getSingleInstanceNormalModeModels(ModelParameterMgr);

% Identify the entries that are mapped in E and F
% Get the IO info
InputInfo = Jfull.Mi.InputInfo;
BlockInputs = InputInfo(:,1);
BlockInputChannels = InputInfo(:,2);

% Next get the actual destinations
p = handle(inpoint);
actdst = getActualDstMdlRef(linutil,p,topmdl,normalmdlblks);

% Get the full names of the input to each of the blocks
blockinputs = zeros(size(actdst,1),1);
for ct = length(blockinputs):-1:1
    inputblockname = get_param(actdst(ct,1),'Parent');
    inputind = find(strcmp(inputblockname,BlockInputNames));
    
    if isempty(inputind)
        blockinputs(ct) = [];
    else
        % Only get a single entry for the inputblockhandle.  This could be
        % repeated.
        inputblockhandle = BlockInputs(inputind(1));
        % Compute port offset
        offset = 0;
        ph = get_param(inputblockhandle,'PortHandles');
        for ct2 = 1:(get_param(actdst(ct,1),'PortNumber')-1)
            offset = offset + get_param(ph.Inport(ct2),'CompiledPortWidth');
        end
        % Index to:
        % act_dst_start:act_dst_start+act_dst_region_length-1
        % Actual Desination Description
        % [output_port_handles, startEl, regionLen]
        blockelementindex = (actdst(ct,2)+1)*(1:actdst(ct,3))+offset;
        inputidx = inputind(blockelementindex == BlockInputChannels(inputind));
        if isempty(inputidx)
            blockinputs(ct) = [];
        else
            blockinputs(ct) = inputidx;
        end
    end
end

% Zero out block outputs connecting to the destination blocks.  Connect
% linearization input points to block inputs.
E = Jfull.Mi.E;
E(blockinputs,:) = 0;
Fmod = sparse(zeros(size(BlockInputs)));
Fmod(blockinputs,1) = 1;
Jfull.Mi.F = Fmod;
Jfull.Mi.H = sparse(1,1);
Jfull.Mi.InputPorts = inpoint;
Jfull.Mi.InputName = get_param(inpoint,'Parent');

% Identify the entry that is mapped in G and map it.
% Get the full names of the output of each of the blocks
OutputInfo = Jfull.Mi.OutputInfo;
BlockOutputs = OutputInfo(:,1);
outputblockname = get_param(outpoint,'Parent');
Gmod = sparse(zeros(1,length(BlockOutputs)));
output_ind = strcmp(outputblockname,BlockOutputNames);
Gmod(output_ind) = 1;
% E(:,output_ind) = 0;
Jfull.Mi.H = sparse(1,1);
% Store the modified interconnections for block reduction
Jfull.Mi.E = E;
Jfull.Mi.G = Gmod;
Jfull.Mi.OutputPorts = outpoint;
Jfull.Mi.OutputName = get_param(outpoint,'Parent');
