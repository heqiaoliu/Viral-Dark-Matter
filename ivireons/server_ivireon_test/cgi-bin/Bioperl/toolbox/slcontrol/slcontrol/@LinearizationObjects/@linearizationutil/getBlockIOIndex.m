function index = getBlockIOIndex(this,src_dst)
% GETBLOCKIOINDEX Get the index of an actual source or destination into a
% block.  This function will take in a list of actual sources or
% destinations and find the flattened index into a block.  Given the
% example below, the block dst has the block, src block block as a source
% given below.
%
%               [3] |-------------|
%          <...-----|             |
%   |-----|     [2] |  src block  |<-----
%   | dst |<--------|             |
%   |-----|         |-------------|
%
% In the case above the src block has two output ports of dimension [3] and
% [2] totaling a flattened list of a vector of length 5.  In this case the 
% block dst indexes into the block list with elements 4 and 5.
%
% Given the next example
%
%               |-------------|  [1]
%          -----|             |<-----
%               |  dst block  |  [2] |-----|
%          -----|             |<-----| src |
%               |-------------|      |-----|
% 
% In the case above the src block has a destination, dst block.  The block
% dst block has two input ports of dimension [1] and [2] totaling 3.  In this 
% case the block src indexes into the block list with elements 2 and 3. 
%
% Usage: SRC_DST is a triplet either source or destination 
%        [port, port offset, port region length]. 
 
% Author(s): John W. Glass 10-Apr-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/05/18 05:59:26 $

% Get the port handle
p = src_dst(1,1);
% Get the parent block
blk = get_param(p,'Parent');
% Get the offset into the connection
p_offset = src_dst(1,2);
% Get the region length of the connection
p_reg = src_dst(1,3);

% If the port number is > 1 then increment to account for the offset.
portnumber = get_param(p,'PortNumber');
porthandles = get_param(blk,'PortHandles');
for ct = 1:portnumber - 1
    p_offset = p_offset + get_param(porthandles.Inport(ct),'CompiledPortWidth');
end

% The index is now the offset + [1:region length of connection]
index = p_offset + (1:p_reg);

