function [isValid, errorMsg] = checkConnection(this)
%CheckConnection Check for valid Simulink connection to block/line.
%   If there are multiple lines/systems selected, verifies that all root
%   models are the same model.  Downselects to a single system if multiple
%   root models were selected.
%
%   Checks that a valid system and block are selected, and that all portIdx
%   entries are valid.  *UPDATES* line handles according to current block
%   wiring.
%
%   If an error is detected, sets .valid=false and .errorMsg is set to a
%   nonempty string.

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/02/02 13:11:31 $

isValid  = false;
errorMsg = '';

sysh = this.System;
if isempty(sysh)
    errorMsg = 'No signal selected.';
    return
end

% Check that sys (block diagram) exists
try
    %blkType = get_param(sysh,'type');
    blkType = sysh.type;
    if ~strcmpi(blkType,'block_diagram')
        errorMsg='System is not a valid block diagram';
        return
    end
catch e %#ok
    errorMsg = 'Invalid system handle';
    return
end

% Check that block exists
try
    % blkType = get_param(this.blkh,'type');
    blkType = this.Block.type;
    if ~strcmpi(blkType,'block')
        errorMsg='Not a Simulink block';
        return
    end
catch e %#ok
    errorMsg = 'Invalid block handle';
    return
end

% Check ports
%
% Simplification/assumption: multi-blocks all are same type, or are
% bus-expansions of the same block.  So just check against FIRST block
%
all_porth = this.Block.PortHandles;
nOutPorts = numel(all_porth.Outport);
if nOutPorts==0
    errorMsg = 'Block has no outputs.';
    return
end
portIdx = this.portIndex;
for i=1:numel(portIdx)
    if (portIdx(i) < 1) || (portIdx(i) > nOutPorts)
        errorMsg = sprintf('Invalid port index: must be from 1 to %d', nOutPorts);
        return
    end
end

% Assume port handles (porth) exist because portIdx are valid

% Lines:
% Here we don't error-check - we UPDATE the line handles
%
% Rationale: it's the BLOCKS and PORTS that matter
%            we just try to keep lines up-to-date
%
% Note: if you select both a bus signal AND one component
% of the bus signal at the same time (presumably the bus
% enters a bus selector block), you will find that you have
% one driver block only, yet there were really two source
% blocks.  The bus is one signal (port 1), but you could have
% selected, say, signal 2 from the bus selector.  So you may
% erroneously try to get port 2 from the block providing the bus
% and it may only have one output port.  Long story short:
% get port handles for each source
%
this.Line=handle([]);
portIdx = this.portIndex;
all_porth = this.Block.PortHandles;
line_handle = get_param(all_porth.Outport(portIdx),'Line');
if line_handle ~= -1
    this.Line = handle(line_handle);
end

% Made it this far - return with success:
isValid = true;

% [EOF]
